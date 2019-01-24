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

  # manage puppet.conf contents, using inifile module
  ['', 'master', 'agent', 'main'].each |$loop_section| {
    $section = $loop_section

    $_removed_settings = []

    # When upgrading to 1.4.x or later remove pluginsync
    $_pkg_version = getvar('package_version')
    if (versioncmp("${_pkg_version}", '1.4.0') >= 0)
        and !defined(Ini_setting["${section}/pluginsync"]) {
      $removed_settings = $_removed_settings + ['pluginsync']
    } else {
      $removed_settings = $_removed_settings
    }

    $removed_settings.each |$setting| {
      ini_setting { "${section}/${setting}":
        ensure  => absent,
        section => $section,
        setting => $setting,
        path    => $puppetconf,
        require => File[$puppetconf],
      }
    }
  }
}
