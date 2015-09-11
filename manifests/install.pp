# == Class puppet_agent::install
#
# This class is called from puppet_agent for install.
#
class puppet_agent::install (
  $version
) {
  assert_private()

  if $::puppet_agent::params::_windows_client {
    class { '::puppet_agent::install::windows':
      version => $version,
    }
    contain '::puppet_agent::install::windows'
  }
  else {
    class { '::puppet_agent::install::default':
      version => $version,
    }
    contain '::puppet_agent::install::default'
  }
}
