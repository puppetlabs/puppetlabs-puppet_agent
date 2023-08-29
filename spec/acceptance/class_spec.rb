require 'beaker-puppet'
require 'spec_helper_acceptance'

describe 'puppet_agent class' do
  context 'default parameters in apply' do
    before(:all) { setup_puppet_on default }
    after(:all) { teardown_puppet_on default }

    describe package(package_name(default)) do
      it { is_expected.to be_installed }
    end

    if %r{windows}i.match?(default['platform'])
      describe service('puppet') do
        # PUPPET_AGENT_STARTUP_MODE=Manual
        it { is_expected.not_to be_enabled }
        it { is_expected.not_to be_running }
      end
    else
      describe service('puppet') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end

    describe file(puppet_conf(default)) do
      it { is_expected.to exist }
      its(:content) do
        is_expected.not_to match(%r{stringify_facts[ ]*=[ ]*false})
        is_expected.not_to match(%r{parser[ ]*=[ ]*future})
      end
    end

    describe 'manage_repo parameter' do
      context 'when true (default)' do
        it 'creates repo config' do
          pp = "class { 'puppet_agent': }"
          apply_manifest(pp, catch_failures: true)
          wait_for_finish_on default
          case default['platform']
          when %r{debian|ubuntu}
            pp = "include apt\napt::source { 'pc_repo': ensure => present, location => 'https://apt.puppet.com', repos => 'puppet5'}"
          when %r{fedora|el|centos}
            pp = "yumrepo { 'pc_repo': ensure => present }"
          else
            logger.notify("Cannot manage repo on #{default['platform']}, skipping test 'should create repo config'")
            next
          end
          apply_manifest(pp, catch_changes: true)
          wait_for_finish_on default
        end
      end

      context 'when false' do
        it 'ceases to manage repo config' do
          pp = "class { 'puppet_agent': }"
          apply_manifest(pp, catch_failures: true)
          wait_for_finish_on default
          case default['platform']
          when %r{debian|ubuntu}
            pp = "include apt\napt::source { 'pc_repo': ensure => absent }"
          when %r{fedora|el|centos}
            pp = "yumrepo { 'pc_repo': ensure => absent }"
          else
            logger.notify("Cannot manage repo on #{default['platform']}, skipping test 'should cease to manage repo config'")
            next
          end
          apply_manifest(pp, catch_failures: true)
          wait_for_finish_on default
          pp = "class { 'puppet_agent': manage_repo => false }"
          # expect no changes now that repo is unmanaged
          apply_manifest(pp, catch_changes: true)
          wait_for_finish_on default
        end
      end
    end
  end

  context 'no services enabled on install' do
    before(:all) { setup_puppet_on default }
    after(:all) { teardown_puppet_on default }

    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'puppet_agent': service_names => [] }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      wait_for_finish_on default
      configure_agent_on default
      apply_manifest(pp, catch_changes: true)
      wait_for_finish_on default
    end

    describe package(package_name(default)) do
      it { is_expected.to be_installed }
    end

    describe service('puppet') do
      it { is_expected.not_to be_running }
    end
  end
end
