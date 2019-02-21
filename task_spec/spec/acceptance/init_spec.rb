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

  def config
    { 'modulepath' => module_path }
  end

  def inventory
    hosts_to_inventory
  end

  it 'works with version and install tasks' do
    # test the agent isn't already installed and that the version task works
    results = run_task('puppet_agent::version', 'target', {}, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).to eq(nil)
    end

    # Try to install an older version
    results = run_task( "puppet_agent::install", 'target', { 'collection' => 'puppet5', 'version' => '5.5.3' }, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
    end

    # It installed a version older than latest
    results = run_task('puppet_agent::version', 'target', {}, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).to eq('5.5.3')
      expect(res['result']['source']).to be
    end

    # Run with no argument upgrades
    results = run_task( "puppet_agent::install", 'target', { 'collection' => 'puppet5' }, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
    end

    # Verify that it upgraded
    results = run_task('puppet_agent::version', 'target', {}, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).not_to eq('5.5.3')
      expect(res['result']['version']).to match(/^5\.\d+\.\d+/)
      expect(res['result']['source']).to be
    end

    # Upgrade from puppet5 to puppet6
    results = run_task( "puppet_agent::install", 'target', { 'collection' => 'puppet6' }, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
    end

    # Verify that it upgraded
    results = run_task('puppet_agent::version', 'target', {}, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['version']).not_to match(/^5\.\d+\.\d+/)
      expect(res['result']['version']).to match(/^6\.\d+\.\d+/)
      expect(res['result']['source']).to be
    end
  end
end
