# == Class puppet_agent::service
#
# This class is meant to be called from puppet_agent.
# It ensures services is running.
#
class puppet_agent::service {
  assert_private()

  $::puppet_agent::service_names.each |$service| {
    service { $service:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }

  if $::operatingsystem == 'Solaris' {
    contain '::puppet_agent::service::solaris'
    Service[$::puppet_agent::service_names] -> Class['::puppet_agent::service::solaris']
  }
}
