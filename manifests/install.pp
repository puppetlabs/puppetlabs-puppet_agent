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
  $version
) {
  assert_private()

  if $::puppet_agent::params::_windows_client {
    class { '::puppet_agent::install::windows':
      version => $version,
    }
    contain '::puppet_agent::install::windows'
  } else {
    class { '::puppet_agent::install::default':
      version => $version,
    }
    contain '::puppet_agent::install::default'
  }
}
