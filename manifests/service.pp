# @summary Ensures that managed services are running.
# This class is meant to be called from puppet_agent.
class puppet_agent::service {
  assert_private()

  $_service_names = $puppet_agent::service_names

  if $facts['os']['name'] == 'Solaris' and $facts['os']['release']['major'] == '10' and versioncmp($facts['clientversion'], '5.0.0') < 0 {
    # Skip managing service, upgrade script will handle it.
  } elsif $facts['os']['name'] == 'Solaris' and $facts['os']['release']['major'] == '11' and $puppet_agent::aio_upgrade_required {
    # Only use script if we just performed an upgrade.
    $_logfile = "${facts['env_temp_variable']}/solaris_start_puppet.log"
    # We'll need to pass the names of the services to start to the script
    $_service_names_arg = join($_service_names, ' ')
    notice ("Puppet service start log file at ${_logfile}")
    file { "${facts['env_temp_variable']}/solaris_start_puppet.sh":
      ensure => file,
      source => 'puppet:///modules/puppet_agent/solaris_start_puppet.sh',
      mode   => '0755',
    }
    -> exec { 'solaris_start_puppet.sh':
      command => "${facts['env_temp_variable']}/solaris_start_puppet.sh ${facts['puppet_agent_pid']} ${_service_names_arg} 2>&1 > ${_logfile} &",
      path    => '/usr/bin:/bin:/usr/sbin',
    }
    file { ['/var/opt/lib', '/var/opt/lib/pe-puppet', '/var/opt/lib/pe-puppet/state']:
      ensure => directory,
    }
  } else {
    $_service_names.each |$service| {
      service { $service:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
      }
    }
  }
}
