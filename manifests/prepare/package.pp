# @summary Ensures correct puppet-agent package is downloaded locally.
# for installation. This is used on platforms without package managers capable of
# working with a remote https repository.
#
# @api private
class puppet_agent::prepare::package (
  Variant[String, Array] $source,
  Optional[String[1]] $destination_name = undef
) {
  assert_private()

  file { $puppet_agent::params::local_packages_dir:
    ensure => directory,
  }

  $package_file_name = if $destination_name {
    $destination_name
  } else {
    # In order for the 'basename' function to work correctly we need to change
    # any \s to /s (even for windows UNC paths) so that it will correctly pull off
    # the filename. Since this operation is only grabbing the base filename and not
    # any part of the path this should be safe, since the source will simply remain
    # what it was before and we can still pull off the filename.
    basename(regsubst($source, "\\\\", '/', 'G'))
  }

  if $facts['os']['family'] =~ /windows/ {
    $local_package_file_path = windows_native_path("${puppet_agent::params::local_packages_dir}/${package_file_name}")
    $mode = undef
  } else {
    $local_package_file_path = "${puppet_agent::params::local_packages_dir}/${package_file_name}"
    $mode = '0644'
  }

  if $puppet_agent::collection =~ /core/ and $facts['os']['family'] =~ /windows/ {
    $download_username = getvar('puppet_agent::username', 'forge-key')
    $download_password = unwrap(getvar('puppet_agent::password'))
    $dev = count(split($puppet_agent::prepare::package_version, '\.')) > 3

    $_download_puppet = windows_native_path("${facts['env_temp_variable']}/download_puppet.ps1")
    file { $_download_puppet:
      ensure  => file,
      content => Sensitive(epp('puppet_agent/download_puppet.ps1.epp')),
    }

    exec { 'Download Puppet Agent':
      command => [
        "${facts['os']['windows']['system32']}\\WindowsPowerShell\\v1.0\\powershell.exe",
        '-ExecutionPolicy',
        'Bypass',
        '-NoProfile',
        '-NoLogo',
        '-NonInteractive',
        $_download_puppet
      ],
      creates => $local_package_file_path,
      require => File[$puppet_agent::params::local_packages_dir],
    }
  } elsif $puppet_agent::collection =~ /core/ and $facts['os']['family'] =~ /Darwin/ {
    $download_username = getvar('puppet_agent::username', 'forge-key')
    $download_password = unwrap(getvar('puppet_agent::password'))

    $response_file = "${local_package_file_path}.response"
    $netrc_file = "${facts['env_temp_variable']}/.netrc"
    file { $netrc_file:
      ensure    => file,
      content   => "machine artifacts-puppetcore.puppet.com\nlogin ${download_username}\npassword ${download_password}\n",
      mode      => '0600',
      show_diff => false,
    }

    $curl_command = "curl --fail -1 -sL --netrc-file '${netrc_file}' -w '%{http_code}' -o '${local_package_file_path}' '${source}' > '${response_file}'"
    exec { 'Download Puppet Agent for Darwin':
      command => $curl_command,
      creates => $local_package_file_path,
      path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    }

    exec { 'Remove .netrc file':
      command => "rm -f '${netrc_file}'",
      path    => ['/usr/bin', '/bin'],
      onlyif  => "test -f '${netrc_file}'",
      require => Exec['Download Puppet Agent for Darwin'],
    }
    #
    # TODO: This is a temporary workaround to get the HTTP response code from the curl command.
    #       For now just outputting the response is good enough.
    #       We need to find a way to interspect this value and fail the catalog if the response
    #       code is not 200, and then logging the output wont be as important.
    #
    exec { 'Read HTTP Response Code':
      command   => "cat '${response_file}'",
      path      => ['/usr/bin', '/bin'],
      onlyif    => "test -f '${response_file}'",
      logoutput => true,
      require   => Exec['Download Puppet Agent for Darwin'],
    }
  } else {
    file { $local_package_file_path:
      ensure  => file,
      owner   => $puppet_agent::params::user,
      group   => $puppet_agent::params::group,
      mode    => $mode,
      source  => $source,
      require => File[$puppet_agent::params::local_packages_dir],
    }
  }
}
