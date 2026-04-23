# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'install task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def module_path
    RSpec.configuration.module_path
  end

  def bolt_config
    { 'modulepath' => module_path }
  end

  def bolt_inventory
    host_data = hosts_to_inventory
    host_data['targets'].each do |node_data|
      node_data['config']['winrm']['connect-timeout'] = 120 if target_platform.include?('win')
    end

    host_data
  end

  def target_platform
    # These tests are configured such that there will only ever be a single host
    # which is what is mapped to 'target' in hosts_to_inventory. This function allows
    # retrieving the target platform for use in obtaining a valid puppet-agent version
    hosts.first[:platform]
  end

  def log_output_errors(result)
    return if result['status'] == 'success'
    out = result.dig('value', '_output') || 'Unknown result output'
    puts logger.info(out)
  end

  # This method lists sources to be used when installing packages that haven't been released yet (see above).
  def latest_sources
    {
      'yum_source'     => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/yum',
      'apt_source'     => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/apt',
      'mac_source'     => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/downloads',
      'windows_source' => 'https://artifactory.delivery.puppetlabs.net:443/artifactory/internal_nightly__local/downloads',
    }
  end

  it 'installs puppetcore8-nightly' do
    results = run_task('puppet_agent::install', 'target',
      {
        'collection' => 'puppetcore8-nightly',
        'version' => 'latest',
        'stop_service' => true
      }.merge(latest_sources))

    results.each do |result|
      logger.info("Installed puppet-agent on #{result['target']}: #{result['status']}")
      log_output_errors(result)
    end

    expect(results).to all(include('status' => 'success'))

    # Check that puppet agent service has been stopped due to 'stop_service' parameter set to true
    service = if target_platform.include?('win')
                run_command('c:/"program files"/"puppet labs"/puppet/bin/puppet resource service puppet', 'target')
              else
                run_command('/opt/puppetlabs/bin/puppet resource service puppet', 'target')
              end
    output = service[0]['value']['stdout']
    expect(output).to match(%r{ensure\s+=> 'stopped'})

    # Check for idempotency
    installed_versions = {}
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      installed_version = res['value']['version']
      installed_versions[target_platform] = installed_version
      expect(installed_version).to match(%r{^8\.\d+\.\d+})
    end

    results = run_task('puppet_agent::install', 'target',
      {
        'collection' => 'puppetcore8-nightly',
        'version'    => installed_versions[target_platform]
      }.merge(latest_sources))

    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['value']['_output']).to match(%r{Puppet Agent #{installed_versions[target_platform]} detected. Nothing to do.})
    end
  end

  # We don't have puppet9 builds for these
  SKIP_PLATFORMS = Regexp.new(<<~END, Regexp::EXTENDED)
    ^amazon-2-|
    ^debian-10-|
    ^el-7-|
    ^fedora-36-|
    ^fedora-40-|
    ^redhatfips-7-|
    ^sles-11-|
    ^solaris-10-|
    ^ubuntu-18.04-|
    ^ubuntu-20.04-|
    ^windows-.*-32
  END

  it 'upgrades to puppetcore9-nightly' do
    if target_platform.match?(SKIP_PLATFORMS)
      logger.info("Platform #{target_platform} isn't supported in puppetcore9, skipping")
    else
      results = run_task('puppet_agent::install', 'target',
        {
          'collection' => 'puppetcore9-nightly',
          'version'    => 'latest',
        }.merge(latest_sources))
      results.each do |result|
        logger.info("Upgraded puppet-agent to puppet9 on #{result['target']}: #{result['status']}")
        log_output_errors(result)
      end

      expect(results).to all(include('status' => 'success'))

      # Verify that it upgraded
      installed_version = nil
      results = run_task('puppet_agent::version', 'target', {})
      results.each do |res|
        expect(res).to include('status' => 'success')
        installed_version = res['value']['version']
        expect(installed_version).to match(%r{^(9\.\d+\.\d+|8\.99\.\d+)})
        expect(res['value']['source']).to be
        logger.info("Successfully upgraded to puppet9 latest version: #{res['value']['version']}")
      end
    end
  end
end
