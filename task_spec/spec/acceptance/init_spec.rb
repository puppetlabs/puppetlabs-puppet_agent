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
    hosts_to_inventory
  end

  def target_platform
    # These tests are configured such that there will only ever be a single host
    # which is what is mapped to 'target' in hosts_to_inventory. This function allows
    # retrieving the target platform for use in obtaining a valid puppet-agent version
    hosts.first[:platform]
  end

  it 'works with version and install tasks' do
    puppet_5_version = case target_platform
                       when %r{fedora-29}
                         '5.5.10'
                       when %r{fedora-30}
                         '5.5.16'
                       when %r{fedora-31}
                         '5.5.18'
                       when %r{osx-10.14}
                         '5.5.12'
                       when %r{osx-10.15}
                         '5.5.19'
                       else
                         '5.5.3'
                       end
    # test the agent isn't already installed and that the version task works
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).to eq(nil)
    end

    # Try to install an older version
    results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet5',
                                                            'version' => puppet_5_version,
                                                            'stop_service' => true })
    results.each do |res|
      expect(res).to include('status' => 'success')
    end

    # It installed a version older than latest
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).to eq(puppet_5_version)
      expect(res['result']['source']).to be
    end

    service = if target_platform =~ /win/
                run_command('c:/"program files"/"puppet labs"/puppet/bin/puppet resource service puppet', 'target')
              else
                run_command('/opt/puppetlabs/bin/puppet resource service puppet', 'target')
              end
    output = service[0]['result']['stdout']
    expect(output).to include("ensure => 'stopped'")

    # Run with no argument upgrades
    results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet5' })
    results.each do |res|
      expect(res).to include('status' => 'success')
    end

    # Verify that it did nothing
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).to eq(puppet_5_version)
      expect(res['result']['source']).to be
    end

    # Run with latest upgrades
    results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet5', 'version' => 'latest' })
    results.each do |res|
      expect(res).to include('status' => 'success')
    end

    # Verify that it upgraded
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).not_to eq(puppet_5_version)
      expect(res['result']['version']).to match(%r{^5\.\d+\.\d+})
      expect(res['result']['source']).to be
    end

    # Upgrade from puppet5 to puppet6
    results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet6', 'version' => 'latest' })
    results.each do |res|
      expect(res).to include('status' => 'success')
    end

    # Verify that it upgraded
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).not_to match(%r{^5\.\d+\.\d+})
      expect(res['result']['version']).to match(%r{^6\.\d+\.\d+})
      expect(res['result']['source']).to be
    end
  end
end
