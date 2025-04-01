# @summary Ensures correct puppet-agent package is downloaded locally.
# for installation. This is used on platforms without package managers capable of
# working with a remote https repository.
#
# @param source
#   The source file for the puppet-agent package. Can use any of the data types
#   and protocols that the File resource's source attribute can.
# @param destination_name
#   The destination file name for the puppet-agent package. If no destination
#   is given, then the basename component of the source will be used as the
#   destination name.
class puppet_agent::prepare::package (
  Variant[String, Array] $source,
  Optional[String] $destination_name = undef
) {
  assert_private()

  file { $puppet_agent::params::local_packages_dir:
    ensure => directory,
  }

  if $destination_name {
    $package_file_name = $destination_name
  } else {
    # In order for the 'basename' function to work correctly we need to change
    # any \s to /s (even for windows UNC paths) so that it will correctly pull off
    # the filename. Since this operation is only grabbing the base filename and not
    # any part of the path this should be safe, since the source will simply remain
    # what it was before and we can still pull off the filename.
    $package_file_name = basename(regsubst($source, "\\\\", '/', 'G'))
  }

  if $facts['os']['family'] =~ /windows/ {
    $local_package_file_path = windows_native_path("${puppet_agent::params::local_packages_dir}/${package_file_name}")
    $mode = undef
  } else {
    $local_package_file_path = "${puppet_agent::params::local_packages_dir}/${package_file_name}"
    $mode = '0644'
  }

  # REMIND: redhat/suse with absolute_source
  # REMIND: debian with absolute_source
  # REMIND: solaris 10
  # REMIND: solaris 11 with manage_repo
  # REMIND: aix
  # REMIND: darwin
  # REMIND: suse 11 and PE
  if $puppet_agent::collection and $puppet_agent::collection =~ /core/ and $facts['os']['family'] =~ /windows/ {
    $download_username = getvar('puppet_agent::username', 'forge-key')
    $download_password = unwrap(getvar('puppet_agent::password'))

    $_download_puppet = windows_native_path("${facts['env_temp_variable']}/download_puppet.ps1")
    file { $_download_puppet:
      ensure  => file,
      content => Sensitive(epp('puppet_agent/download_puppet.ps1.epp')),
    }

    exec { 'Download Puppet Agent':
      command  => "${facts['os']['windows']['system32']}\\WindowsPowerShell\\v1.0\\powershell.exe \
      -ExecutionPolicy Bypass \
      -NoProfile \
      -NoLogo \
      -NonInteractive \
      ${_download_puppet}",
      creates  => $local_package_file_path,
      provider => powershell,
    }
  } elsif $puppet_agent::collection and $puppet_agent::collection =~ /core/ and $facts['os']['family'] =~ /Darwin/ {
    $download_username = getvar('puppet_agent::username', 'forge-key')
    $download_password = unwrap(getvar('puppet_agent::password'))

    $response_file = "${local_package_file_path}.response"
    $netrc_file = "${facts['env_temp_variable']}/.netrc"
    file { $netrc_file:
      ensure  => file,
      content => "machine artifacts-puppetcore.puppet.com\nlogin ${download_username}\npassword ${download_password}\n",
      mode    => '0600',
    }

    $curl_command = "curl -1 -sL --netrc-file '${netrc_file}' -w '%{http_code}' -o '${local_package_file_path}' '${source}' > '${response_file}'"
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
      command => "cat '${response_file}'",
      path    => ['/usr/bin', '/bin'],
      onlyif  => "test -f '${response_file}'",
      logoutput => true,
      require => Exec['Download Puppet Agent for Darwin'],
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
