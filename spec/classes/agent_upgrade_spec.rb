require 'spec_helper'

describe 'agent_upgrade' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        [true, false].each do |mco|
          context "with mcollective_configured = #{mco}" do
            let(:facts) do
              facts.merge({
                :puppet_ssldir   => '/dev/null/ssl',
                :puppet_config   => '/dev/null/puppet.conf',
                :mcollective_configured => mco,
              })
            end

            if Puppet.version < "3.8.0"
              it { expect { is_expected.to contain_package('agent_upgrade') }.to raise_error(Puppet::Error, /upgrading requires Puppet 3.8/) }
            else
              [{}, {:service_names => []}].each do |params|
                context "agent_upgrade class without any parameters" do
                  let(:params) { params }

                  it { is_expected.to compile.with_all_deps }

                  it { is_expected.to contain_class('agent_upgrade') }
                  it { is_expected.to contain_class('agent_upgrade::params') }
                  if Puppet.version < "4.0.0"
                    it { is_expected.to contain_class('agent_upgrade::prepare') }
                    it { is_expected.to contain_class('agent_upgrade::install').that_comes_before('agent_upgrade::config') }
                    it { is_expected.to contain_class('agent_upgrade::config') }
                    it { is_expected.to contain_class('agent_upgrade::service').that_subscribes_to('agent_upgrade::config') }

                    if params[:service_names].nil?
                      it { is_expected.to contain_service('puppet') }
                      it { is_expected.to contain_service('mcollective') }
                    else
                      it { is_expected.to_not contain_service('puppet') }
                      it { is_expected.to_not contain_service('mcollective') }
                    end
                    it { is_expected.to contain_package('puppet-agent').with_ensure('present') }
                  else
                    it { is_expected.to_not contain_service('puppet') }
                    it { is_expected.to_not contain_service('mcollective') }
                    it { is_expected.to_not contain_package('puppet-agent') }
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'agent_upgrade class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
        :puppet_ssldir   => '/dev/null/ssl',
        :puppet_config   => '/dev/null/puppet.conf',
        :mcollective_configured => false,
      }}

      it { expect { is_expected.to contain_package('agent_upgrade') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
