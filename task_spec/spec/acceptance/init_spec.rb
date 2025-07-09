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

  # This method contains a list of platforms that are only available in nightly builds of puppet-agent. Once a regular
  # release of puppet-agent includes support for these platforms, they can be removed from this method and added to
  # the logic that determines the puppet_7_version variable below.
  def latest_platform_list
    %r{
      fedora-41|
      osx-15-arm64|
      osx-15-x86_64|
      amazonfips-2023|
      el-10
    }x
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

  it 'works with version and install tasks' do
    case target_platform
    when latest_platform_list
      # Here we only install puppet-agent 8.x from nightlies as we don't support 7.x
      # We have to consider tests to upgrade puppet 8.x to latest nightlies in future

      # Install an puppet8 nightly version
      results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet8-nightly',
                                                              'version' => 'latest',
                                                              'stop_service' => true }.merge(latest_sources))

      results.each do |result|
        logger.info("Installed puppet-agent on #{result['target']}: #{result['status']}")
        log_output_errors(result)
      end

      expect(results).to all(include('status' => 'success'))

      # Check that puppet agent service has been stopped due to 'stop_service' parameter set to true
      service = run_command('/opt/puppetlabs/bin/puppet resource service puppet', 'target')
      output = service[0]['value']['stdout']
      expect(output).to match(%r{ensure\s+=> 'stopped'})

      # Check for puppet-agent version installed
      results = run_task('puppet_agent::version', 'target', {})
      results.each do |res|
        expect(res).to include('status' => 'success')
        expect(res['value']['version']).to match(%r{^8\.\d+\.\d+})
      end
    else
      # Specify the first released version for each target platform. When adding a new
      # OS, you'll typically want to specify 'latest' to install from nightlies, since
      # official packages won't be released until later. During the N+1 release, you'll
      # want to change `target_platform` to be the first version (N) that added the OS.
      puppet_7_version = case target_platform
                         when %r{debian-11-amd64}
                           '7.9.0'
                         when %r{el-9-x86_64}
                           '7.14.0'
                         when %r{fedora-36}
                           '7.19.0'
                         when %r{osx-11}
                           '7.7.0'
                         when %r{osx-12}, %r{ubuntu-22.04-amd64}
                           '7.18.0'
                         when %r{osx-13}
                           '7.26.0'
                         when %r{el-9-aarch64}, %r{ubuntu-22.04-aarch64}
                           '7.27.0'
                         when %r{amazon-2023}, %r{osx-14}, %r{debian-11-aarch64}
                           '7.28.0'
                         when %r{debian-12}
                           '7.29.0'
                         when %r{el-9-ppc64le}, %r{amazon-2}, %r{fedora-40}
                           '7.31.0'
                         when %r{ubuntu-24.04}
                           '7.32.1'
                         else
                           '7.18.0'
                         end

      puppet_7_collection = 'puppet7'

      # We can only test puppet 7 -> 7 upgrades if multiple Puppet releases
      # have supported a given platform.
      multiple_puppet7_versions = true

      # extra request is needed on windows hosts
      # this will fail with "execution expired"
      run_task('puppet_agent::version', 'target', {}) if target_platform.include?('win')

      # Test the agent isn't already installed and that the version task works
      results = run_task('puppet_agent::version', 'target', {})
      results.each do |res|
        expect(res).to include('status' => 'success')
        expect(res['value']['version']).to eq(nil)
      end

      # Try to install an older puppet7 version
      results = run_task('puppet_agent::install', 'target', { 'collection' => puppet_7_collection,
                                                              'version' => puppet_7_version,
                                                              'stop_service' => true })

      results.each do |result|
        logger.info("Installed puppet-agent on #{result['target']}: #{result['status']}")
        log_output_errors(result)
      end

      expect(results).to all(include('status' => 'success'))

      # It installed a version older than latest puppet7
      results = run_task('puppet_agent::version', 'target', {})
      results.each do |res|
        expect(res).to include('status' => 'success')
        if puppet_7_version == 'latest'
          expect(res['value']['version']).to match(%r{^7\.\d+\.\d+})
        else
          expect(res['value']['version']).to eq(puppet_7_version)
        end
        expect(res['value']['source']).to be
        logger.info("Successfully installed puppet-agent version: #{res['value']['version']}")
      end

      # Check that puppet agent service has been stopped due to 'stop_service' parameter set to true
      service = if target_platform.include?('win')
                  run_command('c:/"program files"/"puppet labs"/puppet/bin/puppet resource service puppet', 'target')
                else
                  run_command('/opt/puppetlabs/bin/puppet resource service puppet', 'target')
                end
      output = service[0]['value']['stdout']
      expect(output).to match(%r{ensure\s+=> 'stopped'})

      # Try to upgrade with no specific version given in parameter
      # Expect nothing to happen and receive a message regarding this
      results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet8-nightly' }.merge(latest_sources))

      results.each do |result|
        logger.info("Ensuring installed puppet-agent on #{result['target']}: #{result['status']}")
        log_output_errors(result)
      end

      results.each do |res|
        expect(res).to include('status' => 'success')
        expect(res['value']['_output']).to match(%r{Version parameter not defined and agent detected. Nothing to do.})
      end

      # Verify that the version didn't change
      results = run_task('puppet_agent::version', 'target', {})
      results.each do |res|
        expect(res).to include('status' => 'success')
        if puppet_7_version == 'latest'
          expect(res['value']['version']).to match(%r{^7\.\d+\.\d+})
        else
          expect(res['value']['version']).to eq(puppet_7_version)
        end
        expect(res['value']['source']).to be
      end

      # An OS needs to be supported for more than one 7.x release to test the
      # upgrade from puppet_7_version to latest
      if multiple_puppet7_versions

        # Upgrade to latest puppet7 version
        results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet7', 'version' => 'latest' })

        results.each do |result|
          logger.info("Upgraded puppet-agent to latest puppet7 on #{result['target']}: #{result['status']}")
          log_output_errors(result)
        end

        expect(results).to all(include('status' => 'success'))

        # Verify that it upgraded
        results = run_task('puppet_agent::version', 'target', {})
        results.each do |res|
          expect(res).to include('status' => 'success')
          expect(res['value']['version']).not_to eq(puppet_7_version)
          expect(res['value']['version']).to match(%r{^7\.\d+\.\d+})
          expect(res['value']['source']).to be
          logger.info("Successfully upgraded to puppet7 latest version: #{res['value']['version']}")
        end
      end

      # Puppet Agent can't be upgraded on Windows nodes while 'puppet agent' service or 'pxp-agent' service are running
      if target_platform.include?('win')
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

      # Succesfully upgrade from puppet7 to puppet8
      results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet8-nightly',
                                                              'version' => 'latest' }.merge(latest_sources))
      results.each do |result|
        logger.info("Upgraded puppet-agent to puppet8 on #{result['target']}: #{result['status']}")
        log_output_errors(result)
      end

      expect(results).to all(include('status' => 'success'))

      # Verify that it upgraded
      installed_version = nil
      results = run_task('puppet_agent::version', 'target', {})
      results.each do |res|
        expect(res).to include('status' => 'success')
        installed_version = res['value']['version']
        expect(installed_version).not_to match(%r{^7\.\d+\.\d+})
        expect(installed_version).to match(%r{^8\.\d+\.\d+})
        expect(res['value']['source']).to be
        logger.info("Successfully upgraded to puppet8 latest version: #{res['value']['version']}")
      end

      # Try installing the same version again
      # Expect nothing to happen and receive a message regarding this
      results = run_task('puppet_agent::install', 'target', { 'collection' => 'puppet8-nightly',
                                                              'version' => installed_version }.merge(latest_sources))
      results.each do |res|
        expect(res).to include('status' => 'success')
        expect(res['value']['_output']).to match(%r{Puppet Agent #{installed_version} detected. Nothing to do.})
      end
    end
  end
end
