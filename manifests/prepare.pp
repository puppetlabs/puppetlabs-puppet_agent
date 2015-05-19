# == Class agent_upgrade::prepare
#
# This class is called from agent_upgrade to prepare for the upgrade.
#
class agent_upgrade::prepare {
  include agent_upgrade::params

  File {
    source_permissions => use,
  }

  # Migrate old files; assumes user Puppet runs under won't change during upgrade
  # We assume the current Puppet settings are authoritative; if anything exists
  # in the destination but not the source, it'll be overwritten.
  file { $::agent_upgrade::params::puppetdirs:
    ensure => directory,
  }

  file { $::agent_upgrade::params::ssldir:
    ensure  => directory,
    source  => $::puppet_ssldir,
    backup  => false,
    recurse => true,
  }

  $puppetconf = $::agent_upgrade::params::config
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
  file { $::agent_upgrade::params::mcodirs:
    ensure => directory,
  }
  # The mco_*_config facts will return the location of mcollective config (or nil), prefering PE over FOSS.
  if $::mco_server_config {
    $mco_server = $::agent_upgrade::params::mco_server
    file { $mco_server:
      ensure  => file,
      source  => $::mco_server_config,
    }

    if $::mco_server_settings {
      $mco_server_libdir = $::mco_server_settings['libdir']
      if $mco_server_libdir {
        $mco_server_libdir_array = split($mco_server_libdir, ':')
        # Only add the new path if it's not already in libdir
        if [] == $mco_server_libdir_array.filter |$x| { $x == $::agent_upgrade::params::mco_libdir } {
          ini_setting { 'server/libdir':
            section => '',
            setting => 'libdir',
            path    => $mco_server,
            value   => "${mco_server_libdir}:$::agent_upgrade::params::mco_libdir",
            require => File[$mco_server],
          }
        }
      }

      $mco_server_plugins = $::mco_server_settings['plugin.yaml']
      if $mco_server_plugins {
        $mco_server_plugins_array = split($mco_server_plugins, ':')
        # Only add the new path if it's not already in plugin.yaml
        if [] == $mco_server_plugins_array.filter |$x| { $x == $::agent_upgrade::params::mco_plugins } {
          ini_setting { 'server/plugin.yaml':
            section => '',
            setting => 'plugin.yaml',
            path    => $mco_server,
            value   => "${mco_server_plugins}:$::agent_upgrade::params::mco_plugins",
            require => File[$mco_server],
          }
        }
      }
    }

    ini_setting { 'server/logfile':
      section => '',
      setting => 'logfile',
      path    => $mco_server,
      value   => $::agent_upgrade::params::mco_log,
      require => File[$mco_server],
    }
  }
  if $::mco_client_config {
    $mco_client = $::agent_upgrade::params::mco_client
    file { $mco_client:
      ensure  => file,
      source  => $::mco_client_config,
    }

    if $::mco_client_settings {
      $mco_client_libdir = $::mco_client_settings['libdir']
      if $mco_client_libdir {
        $mco_client_libdir_array = split($mco_client_libdir, ':')
        # Only add the new path if it's not already in libdir
        if [] == $mco_client_libdir_array.filter |$x| { $x == $::agent_upgrade::params::mco_libdir } {
          ini_setting { 'client/libdir':
            section => '',
            setting => 'libdir',
            path    => $mco_client,
            value   => "${mco_client_libdir}:$::agent_upgrade::params::mco_libdir",
            require => File[$mco_client],
          }
        }
      }

      $mco_client_plugins = $::mco_client_settings['plugin.yaml']
      if $mco_client_plugins {
        $mco_client_plugins_array = split($mco_client_plugins, ':')
        # Only add the new path if it's not already in plugin.yaml
        if [] == $mco_client_plugins_array.filter |$x| { $x == $::agent_upgrade::params::mco_plugins } {
          ini_setting { 'client/plugin.yaml':
            section => '',
            setting => 'plugin.yaml',
            path    => $mco_client,
            value   => "${mco_client_plugins}:$::agent_upgrade::params::mco_plugins",
            require => File[$mco_client],
          }
        }
      }
    }

    ini_setting { 'client/logfile':
      section => '',
      setting => 'logfile',
      path    => $mco_client,
      value   => $::agent_upgrade::params::mco_log,
      require => File[$mco_client],
    }
  }

  # PLATFORM SPECIFIC CONFIGURATION
  # Break out the platform-specific configuration into subclasses, dependent on
  # the osfamily of the client being configured.

  case $::osfamily {
    'redhat', 'debian', 'windows', 'solaris', 'aix', 'suse': {
      contain downcase("::agent_upgrade::osfamily::${::osfamily}")
    }
    default: {
      fail("agent_upgrade not supported on ${::osfamily}")
    }
  }
}
