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
    [# Deprecated settings
     'catalog_format', 'config_version', 'dynamicfacts', 'manifest', 'manifestdir', 'masterlog', 'modulepath', 'parser',
     'stringify_facts', 'templatedir',
     # Database settings for deprecated databases
     'dbadapter', 'dbconnections', 'dblocation', 'dbmigrate', 'dbname', 'dbpassword', 'dbport', 'dbsocket', 'dbuser',
     'rails_loglevel', 'railslog',
     # Settings that should be reset to defaults
     'disable_warnings', 'legacy_query_parameter_serialization', 'vardir', 'rundir', 'libdir', 'confdir'].each |$setting| {
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
