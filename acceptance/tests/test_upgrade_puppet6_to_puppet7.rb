require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest puppet 6 (the puppet6 collection) to puppet 7.0.0.
test_name 'puppet_agent class: Upgrade agents from puppet6 to puppet7' do
  # require_master_collection 'puppet7' #once puppet7 collection is available this can be uncommented
  exclude_pe_upgrade_platforms
  latest_version = `curl http://builds.delivery.puppetlabs.net/passing-agent-SHAs/puppet-agent-main-version`.gsub(/\d*\.\d*.\d*\./,"7.0.0.")
  
  puppet_testing_environment = new_puppet_testing_environment
  step "Create new site.pp with upgrade manifest" do
    manifest = <<-PP
    node default {
      class { puppet_agent:
        package_version => '#{latest_version}',
        apt_source => 'http://nightlies.puppet.com/apt',
        yum_source => 'http://nightlies.puppet.com/yum',
        collection      => 'puppet7-nightly'
      }
    }
    PP
    site_pp_path = File.join(environment_location(puppet_testing_environment), 'manifests', 'site.pp')
    create_remote_file(master, site_pp_path, manifest)
    on(master, %(chown #{puppet_user(master)} "#{site_pp_path}"))
    on(master, %(chmod 755 "#{site_pp_path}"))
  end

  agents_only.each do |agent|
    set_up_initial_agent_on(agent, 'puppet6') do
      step '(Agent) Change agent environment to testing environment' do
        on(agent, puppet("config --section agent set environment #{puppet_testing_environment}"))
        on(agent, puppet("config --section user set environment production"))
      end
    end
  end

  step "Upgrade the agents from Puppet 6 to Puppet 7..." do
    agents_only.each do |agent|
      start_puppet_service_and_wait_for_puppet_run(agent)
      wait_for_installation_pid(agent)
      assert_agent_version_on(agent, latest_version.scan(/7\.\d*\.\d*\.\d*/).first)
    end
  end
end
