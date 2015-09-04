require 'spec_helper'

describe 'puppet_agent' do

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        if Puppet.version < "3.8.0"
          it { expect { is_expected.to contain_package('puppet_agent') }.to raise_error(Puppet::Error, /upgrading requires Puppet 3.8/) }
        else
          [{}, {:service_names => []}].each do |params|
            context "puppet_agent class with parameters #{params}" do
              let(:params) { params }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_class('puppet_agent') }
              it { is_expected.to contain_class('puppet_agent::params') }
              it { is_expected.to contain_class('puppet_agent::prepare') }
              it { is_expected.to contain_class('puppet_agent::install') }
              it { is_expected.to contain_package('puppet-agent').with_ensure('present') }

              if os != 'windows'
                it { is_expected.to contain_class('puppet_agent::service').that_requires('puppet_agent::install') }

                if params[:service_names].nil?
                  it { is_expected.to contain_service('puppet') }
                  it { is_expected.to contain_service('mcollective') }
                else
                  it { is_expected.to_not contain_service('puppet') }
                  it { is_expected.to_not contain_service('mcollective') }
                end
              else
                it { is_expected.to_not contain_service('puppet') }
                it { is_expected.to_not contain_service('mcollective') }
              end
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'puppet_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
        :puppet_ssldir   => '/dev/null/ssl',
        :puppet_config   => '/dev/null/puppet.conf',
      }}

      it { expect { is_expected.to contain_package('puppet_agent') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
