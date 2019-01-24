require 'spec_helper'

MCO_CFG = {:server => '/etc/puppetlabs/mcollective/server.cfg', :client => '/etc/puppetlabs/mcollective/client.cfg'}
MCO_LIBDIR = '/opt/puppetlabs/mcollective/plugins'
MCO_PLUGIN_YAML = '/etc/puppetlabs/mcollective/facts.yaml'
MCO_LOGFILE = '/var/log/puppetlabs/mcollective.log'

describe 'puppet_agent::prepare' do
  context 'supported operating system families' do
    ['Debian', 'RedHat'].each do |osfamily|
      facts = {
        :operatingsystem => 'foo',
        :operatingsystemmajrelease => '42',
        :architecture => 'bar',
        :osfamily => osfamily,
        :lsbdistid => osfamily,
        :lsbdistcodename => 'baz',
        :mco_server_config => nil,
        :mco_client_config => nil,
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

        [
          MCO_CFG,
          {:server => '/etc/mcollective/server.cfg'},
          {:client => '/etc/mcollective/client.cfg'}
        ].each do |mco_config|
          [
            {'libdir' => 'libdir', 'plugin.yaml' => 'plugins'},
            {'libdir' => "libdir:#{MCO_LIBDIR}", 'plugin.yaml' => "plugins:#{MCO_PLUGIN_YAML}"},
            {'libdir' => nil, 'plugin.yaml' => nil},
              nil
          ].each do |mco_settings|
            context "with mco_config = #{mco_config} and mco_settings = #{mco_settings}" do
              let(:facts) {
                facts.merge({
                  :mco_server_config => mco_config[:server],
                  :mco_client_config => mco_config[:client],
                  :mco_server_settings => mco_settings,
                  :mco_client_settings => mco_settings,
                })
              }
            end
          end
        end

        ['', 'agent', 'main', 'master'].each do |section|
          let(:params) {{ package_version: '1.10.100' }}

          it { is_expected.to contain_ini_setting("#{section}/pluginsync").with_ensure('absent') }
        end

        it { is_expected.not_to contain_class("puppet_agent::prepare::ssl") }
        it { is_expected.not_to contain_class("puppet_agent::prepare::mco_client_config") }
        it { is_expected.to contain_class("puppet_agent::prepare::puppet_config") }
        it { is_expected.to contain_class("puppet_agent::osfamily::#{facts[:osfamily]}") }
      end
    end
  end
end
