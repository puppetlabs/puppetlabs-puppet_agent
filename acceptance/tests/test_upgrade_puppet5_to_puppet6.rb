require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest puppet 5 (the puppet5 collection) to puppet 6.0.0.
test_name 'puppet_agent class: collection parameter for FOSS upgrades' do
  require_master_collection 'puppet5'
  exclude_pe_upgrade_platforms

  set_up_agents_to_upgrade('puppet5')

  step "Upgrading the agents from Puppet 5 to Puppet 6..." do
    manifest = <<-PP
  class { puppet_agent:
    package_version => '6.0.0',
    collection      => 'puppet6'
  }
    PP
    apply_manifest_on_agents(manifest)
  end

  assert_successful_upgrade('6.0.0')
end
