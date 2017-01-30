# == Class puppet_agent::prepare::puppet_config
#
# Private class called from puppet_agent::prepare class
#
class puppet_agent::prepare::puppet_config (
  $package_version
) {
  assert_private()
  $old_packages = (versioncmp("${::clientversion}", '4.0.0') < 0)
  $puppetconf = $::puppet_agent::params::config

  if $old_packages {
    file { $puppetconf:
      ensure => file,
      source => $::puppet_config,
    }
  } elsif !defined(File[$puppetconf]) {
    file { $puppetconf:
      ensure => file,
    }
  }

  # manage puppet.conf contents, using inifile module
  ['', 'master', 'agent', 'main'].each |$loop_section| {
    $section = $loop_section

    if versioncmp("${::clientversion}", '4.0.0') < 0 {
      $_removed_settings = [# Removed settings
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
        'disable_warnings', 'vardir', 'rundir', 'libdir', 'confdir', 'ssldir', 'classfile']
    } else {
      $_removed_settings = []
    }

    # When upgrading to 1.4.x or later remove pluginsync
    $_pkg_version = getvar('package_version')
    if (($_pkg_version == undef and $old_packages) or (versioncmp("${_pkg_version}", '1.4.0') >= 0))
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
