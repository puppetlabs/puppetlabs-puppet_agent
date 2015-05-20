# == Class agent_upgrade::prepare
#
# This class is called from agent_upgrade to prepare for the upgrade.
#
class agent_upgrade::prepare {

  File {
    source_permissions => use,
  }

  # Migrate old files; assumes user Puppet runs under won't change during upgrade
  file { ['/etc/puppetlabs', '/etc/puppetlabs/puppet']:
    ensure => directory,
  }

  file { '/etc/puppetlabs/puppet/ssl':
    ensure  => directory,
    source  => $::puppet_ssldir,
    backup  => false,
    recurse => true,
  }

  $puppetconf = '/etc/puppetlabs/puppet/puppet.conf'
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
    file { '/etc/puppetlabs/mcollective':
      ensure => directory,
    }
    file { '/etc/puppetlabs/mcollective/server.cfg':
      ensure => file,
      source => '/etc/mcollective/server.cfg',
    }
  }

  # Install PC1 yum repo; based off puppetlabs_yum
  contain '::agent_upgrade::puppetlabs_yum'
}
