# == Class puppet_agent::prepare::puppet_config
#
# Private class called from puppet_agent::prepare class
#
# MCO Server Config specific config class
#
class puppet_agent::prepare::mco_server_config {
  assert_private()

  $mco_server = $::puppet_agent::params::mco_server
  if !defined(File[$mco_server]) {
    file { $mco_server:
      ensure => file,
      source => $::mco_server_config,
    }

    if $::mco_server_settings {
      $mco_server_libdir = $::mco_server_settings['libdir']
      if $mco_server_libdir {
        $mco_server_libdir_array = split($mco_server_libdir, $::puppet_agent::params::path_separator)
        # Only add the new path if it's not already in libdir; prepend so we prefer versions at the new location
        if [] == $mco_server_libdir_array.filter |$x| { $x == $::puppet_agent::params::mco_libdir } {
          ini_setting { 'server/libdir':
            section => '',
            setting => 'libdir',
            path    => $mco_server,
            value   => "${::puppet_agent::params::mco_libdir}${::puppet_agent::params::path_separator}${mco_server_libdir}",
            require => File[$mco_server],
          }
        }
      }

      $mco_server_plugins = $::mco_server_settings['plugin.yaml']
      if $mco_server_plugins {
        $mco_server_plugins_array = split($mco_server_plugins, $::puppet_agent::params::path_separator)
        # Only add the new path if it's not already in plugin.yaml
        if [] == $mco_server_plugins_array.filter |$x| { $x == $::puppet_agent::params::mco_plugins } {
          ini_setting { 'server/plugin.yaml':
            section => '',
            setting => 'plugin.yaml',
            path    => $mco_server,
            value   => "${mco_server_plugins}${::puppet_agent::params::path_separator}${::puppet_agent::params::mco_plugins}",
            require => File[$mco_server],
          }
        }
      }
    }

    ini_setting { 'server/logfile':
      section => '',
      setting => 'logfile',
      path    => $mco_server,
      value   => $::puppet_agent::params::mco_log,
      require => File[$mco_server],
    }
  }
}
