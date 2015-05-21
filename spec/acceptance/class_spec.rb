require 'spec_helper_acceptance'

describe 'agent_upgrade class' do

  context 'default parameters' do
    before(:all) { setup_puppet_on default }
    after (:all) { teardown_puppet_on default }

    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'agent_upgrade': }
      EOS

      # TODO: Run it twice and test for idempotency; requires ability to change
      #       Beaker config to AIO mid-run.
      apply_manifest(pp, :catch_failures => true)
      #apply_manifest(pp, :catch_changes  => true)
    end

    describe package('puppet-agent') do
      it { is_expected.to be_installed }
    end

    describe service('puppet') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe service('mcollective') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'no services enabled on install' do
    before(:all) { setup_puppet_on default }
    after (:all) { teardown_puppet_on default }

    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'agent_upgrade': service_names => [] }
      EOS

      # TODO: Run it twice and test for idempotency; requires ability to change
      #       Beaker config to AIO mid-run.
      apply_manifest(pp, :catch_failures => true)
      #apply_manifest(pp, :catch_changes  => true)
    end

    describe package('puppet-agent') do
      it { is_expected.to be_installed }
    end

    describe service('puppet') do
      it { is_expected.to_not be_enabled }
      it { is_expected.to_not be_running }
    end

    describe service('mcollective') do
      it { is_expected.to_not be_enabled }
      it { is_expected.to_not be_running }
    end
  end

  context 'with mcollective configured' do
    before(:all) { setup_puppet_on default }
    after (:all) { teardown_puppet_on default }

    it 'should work idempotently with no errors' do
      pp = <<-EOS
      file { '/etc/mcollective': ensure => directory }
      file { '/etc/mcollective/server.cfg':
        ensure  => file,
        notify  => Class['agent_upgrade'],
        content => '#{File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'server.cfg'))}'
      }

      class { 'agent_upgrade': }
      EOS

      # TODO: Run it twice and test for idempotency; requires ability to change
      #       Beaker config to AIO mid-run.
      apply_manifest(pp, :catch_failures => true)
      #apply_manifest(pp, :catch_changes  => true)
    end

    describe package('puppet-agent') do
      it { is_expected.to be_installed }
    end

    describe service('puppet') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe service('mcollective') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  if master
    context 'agent run' do
      before(:all) {
        setup_puppet_on default, true
        pp = "file { '#{master.puppet['confdir']}/manifests/site.pp': ensure => file, content => 'class { \"agent_upgrade\": }' }"
        apply_manifest_on(master, pp, :catch_failures => true)
      }
      after (:all) {
        teardown_puppet_on default
        pp = "file { '#{master.puppet['confdir']}/manifests/site.pp': ensure => absent }"
        apply_manifest_on(master, pp, :catch_failures => true)
      }

      it 'should work idempotently with no errors' do
        with_puppet_running_on(master, parser_opts, master.tmpdir('puppet')) do
          on default, puppet("agent --test --server #{master}"), { :acceptable_exit_codes => [0,2] }
        end
      end

      describe package('puppet-agent') do
        it { is_expected.to be_installed }
      end

      describe service('puppet') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe service('mcollective') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  end
end
