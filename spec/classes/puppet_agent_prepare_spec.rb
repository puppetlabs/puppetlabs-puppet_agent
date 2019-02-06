require 'spec_helper'

RSpec.shared_examples 'removes_deprecated_settings' do |min_version, settings_list|
  describe "deprecated puppet.conf settings in #{min_version}" do
    let(:params) {{ package_version: min_version }}

    ['', 'agent', 'main', 'master'].each do |section|
      settings_list.each do |setting|
        it { is_expected.to contain_ini_setting("#{section}/#{setting}").with_ensure('absent') }
      end
    end
  end
end

describe 'puppet_agent::prepare' do
  context 'supported operating system families' do
    ['Debian', 'RedHat'].each do |osfamily|
      facts = {
        :operatingsystem => 'foo',
        :operatingsystemmajrelease => '42',
        :architecture => 'bar',
        :osfamily => osfamily,
        :lsbdistid => osfamily,
        :lsbdistcodename => 'baz'
      }

      context "on #{osfamily}" do
        let(:facts) { facts }

        include_examples('removes_deprecated_settings', '1.4.0', ['pluginsync'])
        include_examples('removes_deprecated_settings', '5.0.0', ['app_management', 'ignorecache', 'configtimeout', 'trusted_server_facts'])

        it { is_expected.to contain_class("puppet_agent::prepare::puppet_config") }
        it { is_expected.to contain_class("puppet_agent::osfamily::#{facts[:osfamily]}") }
      end
    end
  end
end
