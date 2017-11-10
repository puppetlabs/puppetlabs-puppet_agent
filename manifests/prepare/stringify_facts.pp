# == Class puppet_agent::prepare::stringify_facts
#
# A preperation class to configure the stringify_facts setting to false
#
class puppet_agent::prepare::stringify_facts {

  if (versioncmp($::clientversion, '4.0.0') < 0) {

    ini_setting { 'puppet stringify_facts':
      ensure  => present,
      path    => $::puppet_config,
      section => 'main',
      setting => 'stringify_facts',
      value   => false,
    }

  } else {
    warning('The puppet_agent::prepare::stringify_facts class should only be run on Puppet < 4')
  }

}
