# == Class puppet_agent::service::solaris
#
# This class tidies up the pe-puppet and pe-mcollective services
# which are left running after package removal on Solaris 10.
#
class puppet_agent::service::solaris {
  assert_private()

  if $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '10' {
    service { 'pe-mcollective':
      ensure  => stopped,
    }
    service { 'pe-puppet':
      ensure => stopped,
    }
  } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '11' {
    file { '/tmp/solaris_start_puppet.sh':
      ensure => file,
      source => 'puppet:///modules/puppet_agent/solaris_start_puppet.sh',
      mode   => '0755',
    } ->
    exec { 'solaris_start_puppet.sh':
      command => "/tmp/solaris_start_puppet.sh ${::puppet_agent_pid} &",
      path    => '/usr/bin:/bin:/usr/sbin',
    }
    file { ['/var/opt/lib', '/var/opt/lib/pe-puppet', '/var/opt/lib/pe-puppet/state']:
      ensure => directory,
    }
  }
}
