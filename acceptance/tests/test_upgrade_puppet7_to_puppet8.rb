require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest Puppet 7 (the puppet7-nightly collection)
# to the latest puppet8-nightly build.
test_name 'puppet_agent class: Upgrade agents from puppet7 to puppet8' do
  require_master_collection 'puppet8-nightly'
  exclude_pe_upgrade_platforms
  latest_version = `curl https://builds.delivery.puppetlabs.net/passing-agent-SHAs/puppet-agent-main-version`

  puppet_testing_environment = new_puppet_testing_environment

  step 'Create new site.pp with upgrade manifest' do
    manifest = <<-PP
node default {
  if $facts['os']['family'] =~ /^(?i:windows|solaris|aix|darwin)$/ {
    $_package_version = '#{latest_version}'
  } else {
    $_package_version = 'latest'
  }

  class { puppet_agent:
    package_version => $_package_version,
    apt_source      => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/apt',
    yum_source      => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/yum',
    mac_source      => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/downloads',
    windows_source  => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/downloads',
    collection      => 'puppet8-nightly',
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
    # REMIND: PA-7431 use nightly repos once those release packages are fixed
    set_up_initial_agent_on(agent, puppet_collection: 'puppet7') do
      step '(Agent) Change agent environment to testing environment' do
        on(agent, puppet("config --section agent set environment #{puppet_testing_environment}"))
        on(agent, puppet('config --section user set environment production'))
      end
    end
  end

  step 'Upgrade the agents from Puppet 7 to Puppet 8...' do
    agents_only.each do |agent|
      on(agent, puppet('agent -t --debug'), acceptable_exit_codes: 2)
      wait_for_installation_pid(agent)
      assert(puppet_agent_version_on(agent) =~ %r{^8\.\d+\.\d+.*})
    end
  end

  step 'Run again for idempotency' do
    agents_only.each do |agent|
      on(agent, puppet('agent -t --debug'), acceptable_exit_codes: 0)
    end
  end
end
