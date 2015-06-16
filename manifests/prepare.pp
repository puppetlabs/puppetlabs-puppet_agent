# == Class puppet_agent::prepare
#
# This class is called from puppet_agent to prepare for the upgrade.
#
class puppet_agent::prepare {
  include puppet_agent::params
  $_windows_client = downcase($::osfamily) == 'windows'
  if $_windows_client {
    File{
      source_permissions => ignore,
    }
  }
  else  {
    File {
      source_permissions => use,
    }
  }

  # Migrate old files; assumes user Puppet runs under won't change during upgrade
  # We assume the current Puppet settings are authoritative; if anything exists
  # in the destination but not the source, it'll be overwritten.
  file { $::puppet_agent::params::puppetdirs:
    ensure => directory,
  }

  if !$_windows_client { #Windows didn't change only nix systems
    include puppet_agent::prepare::ssl
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
  if $::mco_server_config and !$_windows_client {
    include puppet_agent::prepare::mco_server_config
  }
  if $::mco_client_config and !$_windows_client {
    include puppet_agent::prepare::mco_client_config
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
