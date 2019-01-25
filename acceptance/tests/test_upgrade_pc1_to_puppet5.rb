require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest puppet 4 (the PC1 collection) to puppet 5.5.10.
# This test will only run if the version of puppet on the master host is less than 5.
test_name 'puppet_agent class: collection parameter for FOSS upgrades' do
  master_agent_version = puppet_agent_version_on(master)

  unless version_is_less(master_agent_version, '5.0.0')
    skip_test("The puppet-agent package on the master is #{master_agent_version}; Skipping PC1 to puppet5 upgrade test")
  end

  upgrade_to = '5.5.10'

  manifest = <<-PP
  class { puppet_agent:
    package_version => '#{upgrade_to}',
    collection      => 'puppet5'
  }
  PP

  run_foss_upgrade_with_manifest('PC1', manifest) do
    agents_only.each do |agent|
      installed_version = puppet_agent_version_on(agent)
      assert_equal(upgrade_to, installed_version,
                   "Expected puppet-agent #{upgrade_to} to be installed on #{agent} (#{agent['platform']}), but found '#{installed_version}'")
    end
  end
end

