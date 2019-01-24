# == Class puppet_agent::prepare::stringify_facts
#
# A preperation class to configure the stringify_facts setting to false
#
class puppet_agent::prepare::stringify_facts {
  warning('The puppet_agent::prepare::stringify_facts class should only be run on Puppet < 4')
}
