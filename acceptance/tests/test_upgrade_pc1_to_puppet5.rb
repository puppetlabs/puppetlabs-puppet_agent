require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest puppet 4 (the PC1 collection) to puppet 5.5.10.
test_name 'puppet_agent class: collection parameter for FOSS upgrades' do
  require_master_collection 'puppet5'
  exclude_pe_upgrade_platforms

  set_up_agents_to_upgrade('pc1')

  step "Upgrading the agents from PC1 to Puppet 5..." do
    manifest = <<-PP
  class { puppet_agent:
    package_version => '5.5.10',
    collection      => 'puppet5'
  }
    PP
    apply_manifest_on_agents(manifest)
  end

  assert_successful_upgrade('5.5.10')
end
