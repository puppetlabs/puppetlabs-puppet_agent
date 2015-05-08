# == Class agent_upgrade::service
#
# This class is meant to be called from agent_upgrade.
# It ensure the service is running.
#
class agent_upgrade::service {

  service { $::agent_upgrade::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
