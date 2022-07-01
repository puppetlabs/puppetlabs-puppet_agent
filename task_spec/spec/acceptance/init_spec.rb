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
      node_data['config']['winrm']['connect-timeout'] = 120 if %r{win}.match?(target_platform)
    end

    host_data
  end

  def target_platform
    # These tests are configured such that there will only ever be a single host
    # which is what is mapped to 'target' in hosts_to_inventory. This function allows
    # retrieving the target platform for use in obtaining a valid puppet-agent version
    hosts.first[:platform]
  end

  it 'works with version and install tasks' do
    puppet_6_version = case target_platform
                       when %r{debian-11}
                         '6.24.0'
                       when %r{el-9}
                         '6.26.0'
                       when %r{fedora-30}
                         '6.19.1'
                       when %r{fedora-31}
                         '6.20.0'
                       when %r{fedora-34}
                         '6.23.0'
                       when %r{osx-10.14}
                         '6.18.0'
                       when %r{osx-10.15}
                         '6.15.0'
                       when %r{osx-11}
                         '6.23.0'
                       when %r{osx-12}
                         '6.27.1'
                       when %r{ubuntu-22.04}
                         'latest'
                       else
                         '6.17.0'
                       end

    # platforms that only have nightly builds available
    case target_platform
    when %r{ubuntu-22.04}
      puppet_6_collection = 'puppet6-nightly'
      puppet_7_collection = 'puppet7-nightly'
    else
      puppet_6_collection = 'puppet6'
      puppet_7_collection = 'puppet7'
    end

    # we can only tests puppet 6.x -> 6.y upgrades if there multiple versions
    multiple_puppet6_versions = case target_platform
                                when %r{osx-12}
                                  false
                                when %r{ubuntu-22.04}
                                  false
                                else
                                  true
                                end

    # extra request is needed on windows hosts
    # this will fail with "execution expired"
    run_task('puppet_agent::version', 'target', {}) if %r{win}.match?(target_platform)

    # Test the agent isn't already installed and that the version task works
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['value']['version']).to eq(nil)
    end

    # Try to install an older puppet6 version
    results = run_task('puppet_agent::install', 'target', { 'collection' => puppet_6_collection,
                                                            'version' => puppet_6_version,
                                                            'stop_service' => true })

    expect(results).to all(include('status' => 'success'))

    # It installed a version older than latest puppet6
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      if puppet_6_version == 'latest'
        expect(res['value']['version']).to match(%r{^6\.\d+\.\d+})
      else
        expect(res['value']['version']).to eq(puppet_6_version)
      end
      expect(res['value']['source']).to be
    end

    # Check that puppet agent service has been stopped due to 'stop_service' parameter set to true
    service = if %r{win}.match?(target_platform)
                run_command('c:/"program files"/"puppet labs"/puppet/bin/puppet resource service puppet', 'target')
              else
                run_command('/opt/puppetlabs/bin/puppet resource service puppet', 'target')
              end
    output = service[0]['value']['stdout']
    expect(output).to match(%r{ensure\s+=> 'stopped'})

    # Try to upgrade with no specific version given in parameter
    # Expect nothing to happen and receive a message regarding this
    results = run_task('puppet_agent::install', 'target', { 'collection' => puppet_6_collection })

    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['value']['_output']).to match(%r{Version parameter not defined and agent detected. Nothing to do.})
    end

    # Verify that the version didn't change
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      if puppet_6_version == 'latest'
        expect(res['value']['version']).to match(%r{^6\.\d+\.\d+})
      else
        expect(res['value']['version']).to eq(puppet_6_version)
      end
      expect(res['value']['source']).to be
    end

    # An OS needs to be supported for more than one 6.x release to test the
    # upgrade from puppet_6_version to latest
    if multiple_puppet6_versions

      # Upgrade to latest puppet6 version
      results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet6', 'version' => 'latest' })
      expect(results).to all(include('status' => 'success'))

      # Verify that it upgraded
      results = run_task('puppet_agent::version', 'target', {})
      results.each do |res|
        expect(res).to include('status' => 'success')
        expect(res['value']['version']).not_to eq(puppet_6_version)
        expect(res['value']['version']).to match(%r{^6\.\d+\.\d+})
        expect(res['value']['source']).to be
      end
    end

    # Puppet Agent can't be upgraded on Windows nodes while 'puppet agent' service or 'pxp-agent' service are running
    if %r{win}.match?(target_platform)
      # Try to upgrade from puppet6 to puppet7 but fail due to puppet agent service already running
      results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet7', 'version' => 'latest' })
      results.each do |res|
        expect(res).to include('status' => 'failure')
        expect(res['value']['_error']['msg']).to match(%r{Puppet Agent upgrade cannot be done while Puppet services are still running.})
      end

      # Manually stop the puppet agent service
      service = run_command('c:/"program files"/"puppet labs"/puppet/bin/puppet resource service puppet ensure=stopped', 'target')
      output = service[0]['value']['stdout']
      expect(output).to match(%r{ensure\s+=> 'stopped'})
    end

    # Succesfully upgrade from puppet6 to puppet7
    results = run_task('puppet_agent::install', 'target', { 'collection' => puppet_7_collection, 'version' => 'latest' })
    expect(results).to all(include('status' => 'success'))

    # Verify that it upgraded
    installed_version = nil
    results = run_task('puppet_agent::version', 'target', {})
    results.each do |res|
      expect(res).to include('status' => 'success')
      installed_version = res['value']['version']
      expect(installed_version).not_to match(%r{^6\.\d+\.\d+})
      expect(installed_version).to match(%r{^7\.\d+\.\d+})
      expect(res['value']['source']).to be
    end

    # Try installing the same version again
    # Expect nothing to happen and receive a message regarding this
    results = run_task('puppet_agent::install', 'target', { 'collection' => puppet_7_collection, 'version' => installed_version })

    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['value']['_output']).to match(%r{Puppet Agent #{installed_version} detected. Nothing to do.})
    end
  end
end
