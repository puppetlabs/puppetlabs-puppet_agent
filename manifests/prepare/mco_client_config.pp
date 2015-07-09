# == Class puppet_agent::prepare::mco_client_config
#
# Private class called from puppet_agent::prepare class
#
# MCO Client Config specific config class
#
class puppet_agent::prepare::mco_client_config {
  assert_private()

  $mco_client = $::puppet_agent::params::mco_client
  file { $mco_client:
    ensure => file,
    source => $::mco_client_config,
  }

  if $::mco_client_settings {
    $mco_client_libdir = $::mco_client_settings['libdir']
    if $mco_client_libdir {
      $mco_client_libdir_array = split($mco_client_libdir, $::puppet_agent::params::path_separator)
    # Only add the new path if it's not already in libdir; prepend so we prefer versions at the new location
      if [] == $mco_client_libdir_array.filter |$x| { $x == $::puppet_agent::params::mco_libdir } {
        ini_setting { 'client/libdir':
          section => '',
          setting => 'libdir',
          path    => $mco_client,
          value   => "${::puppet_agent::params::mco_libdir}${::puppet_agent::params::path_separator}${mco_client_libdir}",
          require => File[$mco_client],
        }
      }
    }

    $mco_client_plugins = $::mco_client_settings['plugin.yaml']
    if $mco_client_plugins {
      $mco_client_plugins_array = split($mco_client_plugins, $::puppet_agent::params::path_separator)
      # Only add the new path if it's not already in plugin.yaml
      if [] == $mco_client_plugins_array.filter |$x| { $x == $::puppet_agent::params::mco_plugins } {
        ini_setting { 'client/plugin.yaml':
          section => '',
          setting => 'plugin.yaml',
          path    => $mco_client,
          value   => "${mco_client_plugins}${::puppet_agent::params::path_separator}${::puppet_agent::params::mco_plugins}",
          require => File[$mco_client],
        }
      }
    }
  }

  ini_setting { 'client/logfile':
    section => '',
    setting => 'logfile',
    path    => $mco_client,
    value   => $::puppet_agent::params::mco_log,
    require => File[$mco_client],
  }
}
