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
    $osname = 'osx'
    $osversion = $facts['os']['macosx']['version']['major']
    $osarch = $facts['os']['architecture']
    $fips = 'false'
    $dev = count(split($puppet_agent::prepare::package_version, '\.')) > 3

    $_download_puppet = "${puppet_agent::params::local_packages_dir}/download_puppet.sh"
    file { $_download_puppet:
      ensure  => file,
      owner   => $puppet_agent::params::user,
      group   => $puppet_agent::params::group,
      mode    => '0700',
      content => Sensitive(epp('puppet_agent/download_puppet.sh.epp')),
    }

    exec { 'Download Puppet Agent':
      command => [$_download_puppet],
      creates => $local_package_file_path,
      require => File[$puppet_agent::params::local_packages_dir],
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
