# == Class puppet_agent::prepare
#
# This class is called from puppet_agent to prepare for the upgrade.
#
class puppet_agent::prepare {
  include puppet_agent::params

  File {
    source_permissions => use,
  }

  # Migrate old files; assumes user Puppet runs under won't change during upgrade
  # We assume the current Puppet settings are authoritative; if anything exists
  # in the destination but not the source, it'll be overwritten.
  file { $::puppet_agent::params::puppetdirs:
    ensure => directory,
  }

  file { $::puppet_agent::params::ssldir:
    ensure  => directory,
    source  => $::puppet_ssldir,
    backup  => false,
    recurse => true,
  }

  $puppetconf = $::puppet_agent::params::config
  file { $puppetconf:
    ensure => file,
    source => $::puppet_config,
  }

  # manage puppet.conf contents, using inifile module
  ['master', 'agent', 'main'].each |$section| {
    [# Removed settings
     'allow_variables_with_dashes', 'async_storeconfigs', 'binder', 'catalog_format', 'certdnsnames',
     'certificate_expire_warning', 'couchdb_url', 'dbadapter', 'dbconnections', 'dblocation', 'dbmigrate', 'dbname',
     'dbpassword', 'dbport', 'dbserver', 'dbsocket', 'dbuser', 'dynamicfacts', 'http_compression', 'httplog',
     'ignoreimport', 'immutable_node_data', 'inventory_port', 'inventory_server', 'inventory_terminus',
     'legacy_query_parameter_serialization', 'listen', 'localconfig', 'manifestdir', 'masterlog', 'parser',
     'preview_outputdir', 'puppetport', 'queue_source', 'queue_type', 'rails_loglevel', 'railslog',
     'report_serialization_format', 'reportfrom', 'rrddir', 'rrdinterval', 'sendmail', 'smtphelo', 'smtpport',
     'smtpserver', 'stringify_facts', 'tagmap', 'templatedir', 'thin_storeconfigs', 'trusted_node_data', 'zlib', 
     # Deprecated for global config
     'config_version', 'manifest', 'modulepath',
     # Settings that should be reset to defaults
     'disable_warnings', 'vardir', 'rundir', 'libdir', 'confdir', 'ssldir'].each |$setting| {
      ini_setting { "${section}/${setting}":
        ensure  => absent,
        section => $section,
        setting => $setting,
        path    => $puppetconf,
        require => File[$puppetconf],
      }
    }
  }

  # manage client.cfg and server.cfg contents
  file { $::puppet_agent::params::mcodirs:
    ensure => directory,
  }
  # The mco_*_config facts will return the location of mcollective config (or nil), prefering PE over FOSS.
  if $::mco_server_config {
    $mco_server = $::puppet_agent::params::mco_server
    file { $mco_server:
      ensure  => file,
      source  => $::mco_server_config,
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
  if $::mco_client_config {
    $mco_client = $::puppet_agent::params::mco_client
    file { $mco_client:
      ensure  => file,
      source  => $::mco_client_config,
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

  # PLATFORM SPECIFIC CONFIGURATION
  # Break out the platform-specific configuration into subclasses, dependent on
  # the osfamily of the client being configured.

  case $::osfamily {
    'redhat', 'debian', 'windows', 'solaris', 'aix', 'suse': {
      contain downcase("::puppet_agent::osfamily::${::osfamily}")
    }
    default: {
      fail("puppet_agent not supported on ${::osfamily}")
    }
  }
}
