require 'beaker-puppet'
require_relative '../helpers'

# Tests FOSS upgrades from the latest Puppet 8 (the puppet8-nightly collection)
# to the latest puppet9-nightly build.
test_name 'puppet_agent class: Upgrade agents from puppet8 to puppet9' do
  # puppet9-nightly puppetserver may not yet be published; accept a puppet8 or
  # newer master so the test can run while agents are upgraded to puppet9.
  # puppet_collection_for(:puppetserver, ...) returns bare 'puppet8'/'puppet9'
  # (no -nightly suffix), so compare against the bare collection name.
  require_master_collection min: 'puppet8'
  exclude_pe_upgrade_platforms

  # Both passing-agent-SHAs lookups have to succeed; if VPN/network flaps and
  # either returns empty, the test silently degrades (empty package_version
  # crashes the puppet_agent class; empty SHA produces a nonsense dev_builds
  # URL). Use curl --retry and assert non-empty.
  curl_passing_sha = ->(name) do
    out = `curl --silent --fail --retry 5 --retry-delay 3 --retry-connrefused --max-time 30 https://builds.delivery.puppetlabs.net/passing-agent-SHAs/#{name}`.strip
    fail_test("Failed to fetch passing-agent-SHAs/#{name} from builds.delivery.puppetlabs.net; check VPN") if out.empty?
    out
  end

  latest_version = curl_passing_sha.call('puppet-agent-9.x-version')
  logger.info("Using latest puppet-agent-9.x #{latest_version}")

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
    collection      => 'puppet9-nightly',
    service_names   => []
  }
}
    PP
    site_pp_path = File.join(environment_location(puppet_testing_environment), 'manifests', 'site.pp')
    create_remote_file(master, site_pp_path, manifest)
    on(master, %(chown #{puppet_user(master)} "#{site_pp_path}"))
    on(master, %(chmod 755 "#{site_pp_path}"))
  end

  # Newer agent platforms (e.g. macOS 26) don't have puppet-agent 8 builds at
  # the public downloads.puppet.com/mac/puppet8/... path. Passing an explicit
  # puppet_agent_version routes install_puppet_agent_on through dev_builds_url
  # (https://builds.delivery.puppetlabs.net), which serves per-SHA artifacts at
  # /puppet-agent/<full-sha>/artifacts/<full-sha>.yaml. The `puppet-agent-8.x`
  # file under passing-agent-SHAs/ holds that full SHA; the `-version` sibling
  # is a human-readable version+short-sha that beaker can't resolve to a YAML.
  initial_agent_version = ENV['INITIAL_PUPPET_AGENT_VERSION'] || curl_passing_sha.call('puppet-agent-8.x')
  logger.info("Using puppet-agent 8.x ref for initial agent install: #{initial_agent_version}")
  agents_only.each do |agent|
    # REMIND: PA-7431 use nightly repos once those release packages are fixed
    set_up_initial_agent_on(agent, puppet_collection: 'puppet8', puppet_agent_version: initial_agent_version) do
      step '(Agent) Change agent environment to testing environment' do
        on(agent, puppet("config --section agent set environment #{puppet_testing_environment}"))
        on(agent, puppet('config --section user set environment production'))
      end
    end
  end

  step 'Upgrade the agents from Puppet 8 to Puppet 9...' do
    agents_only.each do |agent|
      # Accept any exit code so we can dump the full puppet apply output on
      # failure; beaker's default truncates to the last 10 lines.
      result = on(agent, puppet('agent -t --debug'), accept_all_exit_codes: true)
      unless result.exit_code == 2
        logger.error("=== puppet agent -t output on #{agent} (exit #{result.exit_code}) ===")
        logger.error(result.stdout)
        logger.error(result.stderr) unless result.stderr.empty?
        logger.error('=== end output ===')
        fail_test("puppet agent -t expected exit 2 (changes applied) on #{agent}, got exit #{result.exit_code}")
      end
      wait_for_installation_pid(agent)
      # Pre-release puppet9 nightlies report as 8.99.99.<build>.g<sha> (Puppet's
      # next-major pre-release convention); accept those alongside the eventual
      # stable 9.x.y form.
      assert(puppet_agent_version_on(agent) =~ %r{^(?:9\.\d+\.\d+|8\.99\.99\.\d+).*})
    end
  end

  step 'Run again for idempotency' do
    agents_only.each do |agent|
      on(agent, puppet('agent -t --debug'), acceptable_exit_codes: 0)
    end
  end
end
