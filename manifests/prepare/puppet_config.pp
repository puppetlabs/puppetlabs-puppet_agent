# == Class puppet_agent::prepare::puppet_config
#
# Private class called from puppet_agent::prepare class
#
class puppet_agent::prepare::puppet_config (
  $package_version
) {
  assert_private()
  $puppetconf = $::puppet_agent::params::config

  if !defined(File[$puppetconf]) {
    file { $puppetconf:
      ensure => file,
    }
  }

  # (minimum agent package version) => (list of deprecated settings)
  $_deprecations = {
    '1.4.0'     => ['pluginsync'],
    '5.0.0'     => ['app_management', 'ignorecache', 'configtimeout', 'trusted_server_facts']
  }

  $_pkg_version = getvar('package_version')

  # manage puppet.conf contents, using inifile module
  $_deprecations.each |$_min_version, $_setting_names| {
    if (versioncmp("${_pkg_version}", "${_min_version}") >= 0) {
      $_setting_names.each |$_setting_name| {
        ['', 'master', 'agent', 'main'].each |$_section_name| {
          $_setting_key = "${_section_name}/${_setting_name}"

          if !defined(Ini_setting[$_setting_key]) {
            ini_setting { $_setting_key:
              ensure  => absent,
              section => $_section_name,
              setting => $_setting_name,
              path    => $puppetconf,
              require => File[$puppetconf],
            }
          }
        }
      }
    }
  }
}
