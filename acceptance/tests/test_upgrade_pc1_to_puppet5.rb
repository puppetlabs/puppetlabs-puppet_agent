require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest puppet 4 (the PC1 collection) to puppet 5.5.10.
test_name 'puppet_agent class: Upgrade agents from PC1 (puppet 4) to puppet5' do
  require_master_collection 'puppet5'
  exclude_pe_upgrade_platforms

  puppet_testing_environment = new_puppet_testing_environment

  step "Create new site.pp with upgrade manifest" do
    manifest = <<-PP
node default {
  class { puppet_agent:
    package_version => '5.5.10',
    collection      => 'puppet5'
  }
}
    PP
    site_pp_path = File.join(environment_location(puppet_testing_environment), 'manifests', 'site.pp')
    create_remote_file(master, site_pp_path, manifest)
    on(master, %(chown #{puppet_user(master)} "#{site_pp_path}"))
    on(master, %(chmod 755 "#{site_pp_path}"))
  end

  agents_only.each do |agent|
    set_up_initial_agent_on(agent, 'pc1') do
      step '(Agent) Change agent environment to testing environment' do
        on(agent, puppet("config --section agent set environment #{puppet_testing_environment}"))
        on(agent, puppet("config --section user set environment production"))
      end
    end
  end

  step "Upgrade the agents from Puppet 4 to Puppet 5..." do
    agents_only.each do |agent|
      start_puppet_service_and_wait_for_puppet_run(agent)
      wait_for_installation_pid(agent)
      assert_agent_version_on(agent, '5.5.10')
    end
  end
end
