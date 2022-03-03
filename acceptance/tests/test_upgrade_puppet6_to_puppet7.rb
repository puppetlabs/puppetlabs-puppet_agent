require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest puppet 6 (the puppet6-nightly collection)
# to the latest puppet7-nightly build.
test_name 'puppet_agent class: Upgrade agents from puppet6 to puppet7' do
  require_master_collection 'puppet7-nightly'
  exclude_pe_upgrade_platforms
  latest_version = `curl http://builds.delivery.puppetlabs.net/passing-agent-SHAs/puppet-agent-main-version`

  puppet_testing_environment = new_puppet_testing_environment

  step 'Create new site.pp with upgrade manifest' do
    manifest = <<-PP
node default {
  if $::osfamily =~ /^(?i:windows|solaris|aix|darwin)$/ {
    $_package_version = '#{latest_version}'
  } else {
    $_package_version = 'latest'
  }

  class { puppet_agent:
    package_version => $_package_version,
    apt_source      => 'http://nightlies.puppet.com/apt',
    yum_source      => 'http://nightlies.puppet.com/yum',
    mac_source      => 'http://nightlies.puppet.com/downloads',
    windows_source  => 'http://nightlies.puppet.com/downloads',
    collection      => 'puppet7-nightly',
    service_names   => []
  }
}
    PP
    site_pp_path = File.join(environment_location(puppet_testing_environment), 'manifests', 'site.pp')
    create_remote_file(master, site_pp_path, manifest)
    on(master, %(chown #{puppet_user(master)} "#{site_pp_path}"))
    on(master, %(chmod 755 "#{site_pp_path}"))
  end

  agents_only.each do |agent|
    set_up_initial_agent_on(agent, 'puppet6-nightly') do
      step '(Agent) Change agent environment to testing environment' do
        on(agent, puppet("config --section agent set environment #{puppet_testing_environment}"))
        on(agent, puppet('config --section user set environment production'))
      end
    end
  end

  step 'Upgrade the agents from Puppet 6 to Puppet 7...' do
    agents_only.each do |agent|
      on(agent, puppet('agent -t --debug'), acceptable_exit_codes: 2)
      wait_for_installation_pid(agent)
      assert(puppet_agent_version_on(agent) =~ %r{^7\.\d+\.\d+.*})
    end
  end

  step 'Run again for idempotency' do
    agents_only.each do |agent|
      on(agent, puppet('agent -t --debug'), acceptable_exit_codes: 0)
    end
  end
end
