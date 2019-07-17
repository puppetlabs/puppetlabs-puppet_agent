require 'beaker-puppet'
require 'spec_helper_acceptance'


describe 'puppet_agent class' do

  context 'default parameters in apply' do
    before(:all) { setup_puppet_on default }
    after (:all) { teardown_puppet_on default }

    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'puppet_agent': package_version => '5.5.14', collection => 'puppet5' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      wait_for_finish_on default
      configure_agent_on default
      apply_manifest(pp, :catch_changes  => true)
      wait_for_finish_on default
    end

    describe package(package_name(default)) do
      it { is_expected.to be_installed }
    end

    if default['platform'] =~ /windows/i
      # MODULES-4244: MCollective not started after upgrade
      describe service('mcollective') do
        it { is_expected.to_not be_enabled }
        it { is_expected.to_not be_running }
      end

      describe service('puppet') do
        # PUPPET_AGENT_STARTUP_MODE=Manual
        it { is_expected.to_not be_enabled }
        it { is_expected.to_not be_running }
      end
    else
      describe service('mcollective') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe service('puppet') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end

    describe file(puppet_conf(default)) do
      it { is_expected.to exist }
      its(:content) {
        is_expected.to_not match /stringify_facts[ ]*=[ ]*false/
        is_expected.to_not match /parser[ ]*=[ ]*future/
      }
    end

    describe 'manage_repo parameter' do
      context 'when true (default)' do
        it 'should create repo config' do
          pp = "class { 'puppet_agent': }"
          apply_manifest(pp, :catch_failures => true)
          wait_for_finish_on default
          case default['platform']
          when /debian|ubuntu/
            pp = "include apt\napt::source { 'pc_repo': ensure => present, location => 'https://apt.puppet.com', repos => 'puppet5'}"
          when /fedora|el|centos/
            pp = "yumrepo { 'pc_repo': ensure => present }"
          else
            logger.notify("Cannot manage repo on #{default['platform']}, skipping test 'should create repo config'")
            next
          end
          apply_manifest(pp, :catch_changes => true)
          wait_for_finish_on default
        end
      end

      context 'when false' do
        it 'should cease to manage repo config' do
          pp = "class { 'puppet_agent': }"
          apply_manifest(pp, :catch_failures => true)
          wait_for_finish_on default
          case default['platform']
          when /debian|ubuntu/
            pp = "include apt\napt::source { 'pc_repo': ensure => absent }"
          when /fedora|el|centos/
            pp = "yumrepo { 'pc_repo': ensure => absent }"
          else
            logger.notify("Cannot manage repo on #{default['platform']}, skipping test 'should cease to manage repo config'")
            next
          end
          apply_manifest(pp, :catch_failures => true)
          wait_for_finish_on default
          pp = "class { 'puppet_agent': manage_repo => false }"
          # expect no changes now that repo is unmanaged
          apply_manifest(pp, :catch_changes => true)
          wait_for_finish_on default
        end
      end
    end
  end

  context 'no services enabled on install' do
    before(:all) { setup_puppet_on default }
    after (:all) { teardown_puppet_on default }

    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'puppet_agent': service_names => [] }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      wait_for_finish_on default
      configure_agent_on default
      apply_manifest(pp, :catch_changes  => true)
      wait_for_finish_on default
    end

    describe package(package_name(default)) do
      it { is_expected.to be_installed }
    end

    describe service('puppet') do
      it { is_expected.to_not be_running }
    end

    describe service('mcollective') do
      it { is_expected.to_not be_running }
    end
  end

  unless default['platform'] =~ /windows/i
    # MODULES-4244: MCollective not started after upgrade
    context 'with mcollective configured' do
      before(:all) {
        setup_puppet_on default, :mcollective => true, :agent => true
        manifest = 'class { "puppet_agent": package_version => "5.5.14", collection => "puppet5", service_names => ["mcollective"] }'
        pp = "file { '#{master.puppet['codedir']}/environments/production/manifests/site.pp': ensure => file, content => '#{manifest}' }"
        apply_manifest_on(master, pp, :catch_failures => true)
      }
      after (:all) {
        pp = "file { '#{master.puppet['codedir']}/environments/production/manifests/site.pp': ensure => absent }"
        apply_manifest_on(master, pp, :catch_failures => true)
        teardown_puppet_on default
      }

      it 'mco should be running' do
        on default, 'mco ping' do
          hostname = default.hostname.split('.', 2).first
          assert_match(/^#{hostname}[.\w]*\s+time=/, stdout)
        end
      end

      it 'should work idempotently with no errors' do
        pp = <<-EOS
      class { 'puppet_agent':  collection => "puppet5", service_names => ["mcollective"] }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        wait_for_finish_on default
        configure_agent_on default
        apply_manifest(pp, :catch_changes  => true)
        wait_for_finish_on default
      end

      describe package(package_name(default)) do
        it { is_expected.to be_installed }
      end

      describe service('mcollective') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      it 'should have mcollective correctly configured' do
        on default, 'mco ping' do
          hostname = default.hostname.split('.', 2).first
          assert_match(/^#{hostname}[.\w]*\s+time=/, stdout)
        end
      end
    end
  end
end
