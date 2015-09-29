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
  }
}
