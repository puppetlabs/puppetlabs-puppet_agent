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

  # TODO: manage server.cfg contents
  if $::mcollective_configured {
    file { $::agent_upgrade::params::mcodirs:
      ensure => directory,
    }
    file { $::agent_upgrade::params::mcoserver:
      ensure => file,
      source => $::agent_upgrade::params::oldmcoserver,
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
