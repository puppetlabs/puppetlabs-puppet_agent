require 'spec_helper'

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

        context "when SSL paths do not exist" do
          let(:facts) {
            facts.merge({ :puppet_sslpaths => {
              'privatedir' => { 'path_exists' => false },
              'privatekeydir' => { 'path_exists' => false },
              'publickeydir' => { 'path_exists' => false },
              'certdir' => { 'path_exists' => false },
              'requestdir' => { 'path_exists' => false },
              'hostcrl' => { 'path_exists' => false }
            }})
          }
        end

        ['', 'agent', 'main', 'master'].each do |section|
          let(:params) {{ package_version: '1.10.100' }}

          it { is_expected.to contain_ini_setting("#{section}/pluginsync").with_ensure('absent') }
        end

        it { is_expected.to contain_class("puppet_agent::prepare::puppet_config") }
        it { is_expected.to contain_class("puppet_agent::osfamily::#{facts[:osfamily]}") }
      end
    end
  end
end
