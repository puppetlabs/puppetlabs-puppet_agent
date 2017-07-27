# == Class puppet_agent::service
#
# This class is meant to be called from puppet_agent.
# It ensures services is running.
#
class puppet_agent::service {
  assert_private()

  if $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '11' {
    file { '/tmp/solaris_start_puppet.sh':
      ensure => file,
      source => 'puppet:///modules/puppet_agent/solaris_start_puppet.sh',
      mode   => '0755',
    }
    -> exec { 'solaris_start_puppet.sh':
      command => "/tmp/solaris_start_puppet.sh ${::puppet_agent_pid} &",
      path    => '/usr/bin:/bin:/usr/sbin',
    }
    file { ['/var/opt/lib', '/var/opt/lib/pe-puppet', '/var/opt/lib/pe-puppet/state']:
      ensure => directory,
    }
  } else {

    $::puppet_agent::service_names.each |$service| {
      service { $service:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
      }
    }
  }
}
