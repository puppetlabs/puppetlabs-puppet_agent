# == Class puppet_agent::install
#
# This class is called from puppet_agent for install.
#
# === Parameters
#
# [package_file_name]
#   The puppet-agent package file name.
#   (see puppet_agent::prepare::package_file_name)
#
# [version]
#   The puppet-agent version to install.
class puppet_agent::install(
  $package_file_name = undef,
  $package_version
) {
  assert_private()

  if $::puppet_agent::params::_windows_client {
    class { '::puppet_agent::windows::install':
      package_version    => $package_version,
    }
    contain '::puppet_agent::windows::install'
  } else {
    class { '::puppet_agent::install::default':
      package_file_name => $package_file_name,
      package_version   => $package_version,
    }
    contain '::puppet_agent::install::default'
  }
}
