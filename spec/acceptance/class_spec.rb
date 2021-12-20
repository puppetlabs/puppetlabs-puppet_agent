require 'beaker-puppet'
require 'spec_helper_acceptance'

describe 'puppet_agent class' do
  context 'default parameters in apply' do
    before(:all) { setup_puppet_on default }
    after(:all) { teardown_puppet_on default }

    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'puppet_agent': package_version => '5.5.21', collection => 'puppet5' }
      EOS

      apply_manifest(pp, catch_failures: true)
      wait_for_finish_on default
      configure_agent_on default
      # Run three times to ensure idempotency if upgrading with the package resource (MODULES-10666)
      unless %r{solaris-10|aix|osx|windows}i.match?(default['platform'])
        apply_manifest(pp, expect_changes: true)
        wait_for_finish_on default
      end
      apply_manifest(pp, catch_changes: true)
    end

    describe package(package_name(default)) do
      it { is_expected.to be_installed }
    end

    if %r{windows}i.match?(default['platform'])
      # MODULES-4244: MCollective not started after upgrade
      describe service('mcollective') do
        it { is_expected.not_to be_enabled }
        it { is_expected.not_to be_running }
      end

      describe service('puppet') do
        # PUPPET_AGENT_STARTUP_MODE=Manual
        it { is_expected.not_to be_enabled }
        it { is_expected.not_to be_running }
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

    describe service('mcollective') do
      it { is_expected.not_to be_running }
    end
  end

  unless %r{windows}i.match?(default['platform'])
    # MODULES-4244: MCollective not started after upgrade
    context 'with mcollective configured' do
      before(:all) do
        setup_puppet_on default, mcollective: true, agent: true
        manifest = 'class { "puppet_agent": package_version => "5.5.21", collection => "puppet5", service_names => ["mcollective"] }'
        pp = "file { '#{master.puppet['codedir']}/environments/production/manifests/site.pp': ensure => file, content => '#{manifest}' }"
        apply_manifest_on(master, pp, catch_failures: true)
      end
      after(:all) do
        pp = "file { '#{master.puppet['codedir']}/environments/production/manifests/site.pp': ensure => absent }"
        apply_manifest_on(master, pp, catch_failures: true)
        teardown_puppet_on default
      end
      # rubocop:disable RepeatedExample

      it 'mco should be running' do
        on default, 'mco ping' do
          hostname = default.hostname.split('.', 2).first
          assert_match(%r{^#{hostname}[.\w]*\s+time=}, stdout)
        end
      end
      # rubocop:enable RepeatedExample

      it 'works idempotently with no errors' do
        pp = <<-EOS
      class { 'puppet_agent':  collection => "puppet5", service_names => ["mcollective"] }
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

      describe service('mcollective') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      # rubocop:disable RepeatedExample
      it 'has mcollective correctly configured' do
        on default, 'mco ping' do
          hostname = default.hostname.split('.', 2).first
          assert_match(%r{^#{hostname}[.\w]*\s+time=}, stdout)
        end
      end
      # rubocop:enable RepeatedExample
    end

    unless %r{solaris-10|aix|osx|windows}i.match?(default['platform'])
      context 'on platforms managed with the package resource' do
        before(:all) { setup_puppet_on default }

        after(:all) do
          on default, 'rm -f /tmp/a'
          teardown_puppet_on default
        end

        let(:manifest) do
          <<-EOS
      class { 'puppet_agent': package_version => '5.5.21', collection => 'puppet5', before => File['/tmp/a'] }
      file { '/tmp/a': ensure => 'present' }
      EOS
        end

        it 'upgrades the agent on the first run' do
          # First run should upgrade the agent
          apply_manifest(manifest, expect_changes: true)
          configure_agent_on default
          expect(package(package_name(default))).to be_installed
          expect(file('/tmp/a')).not_to exist
        end

        it 'evaluates remanining resources on the second run' do
          # Second run should apply the file resource
          apply_manifest(manifest, expect_changes: true)
          expect(file('/tmp/a')).to exist
        end

        it 'does nothing on future runs' do
          # Third run should not do anything
          apply_manifest(manifest, catch_changes: true)
        end
      end
    end
  end
end
