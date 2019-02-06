require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest puppet 5 (the puppet5 collection) to puppet 6.0.0.
test_name 'puppet_agent class: Upgrade agents from puppet5 to puppet6' do
  require_master_collection 'puppet6'
  exclude_pe_upgrade_platforms

  puppet_testing_environment = new_puppet_testing_environment

  step "Create new site.pp with upgrade manifest" do
    manifest = <<-PP
node default {
  class { puppet_agent:
    package_version => '6.0.0',
    collection      => 'puppet6'
  }
}
    PP
    site_pp_path = File.join(environment_location(puppet_testing_environment), 'manifests', 'site.pp')
    create_remote_file(master, site_pp_path, manifest)
    on(master, %(chown #{puppet_user(master)} "#{site_pp_path}"))
    on(master, %(chmod 755 "#{site_pp_path}"))
  end

  agents_only.each do |agent|
    set_up_initial_agent_on(agent, 'puppet5') do
      step '(Agent) Change agent environment to testing environment' do
        on(agent, puppet("config --section agent set environment #{puppet_testing_environment}"))
        on(agent, puppet("config --section user set environment production"))
      end
    end
  end

  step "Upgrade the agents from Puppet 5 to Puppet 6..." do
    agents_only.each do |agent|
      start_puppet_service_and_wait_for_puppet_run(agent)
      wait_for_installation_pid(agent)
      assert_agent_version_on(agent, '6.0.0')
    end
  end
end
