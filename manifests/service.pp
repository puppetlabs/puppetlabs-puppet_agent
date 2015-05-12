# == Class agent_upgrade::service
#
# This class is meant to be called from agent_upgrade.
# It ensures services is running.
#
class agent_upgrade::service {

  $::agent_upgrade::service_names.each |$service| {
    service { $service:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
