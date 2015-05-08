require 'spec_helper'

describe 'agent_upgrade' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "agent_upgrade class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('agent_upgrade::params') }
          it { is_expected.to contain_class('agent_upgrade::install').that_comes_before('agent_upgrade::config') }
          it { is_expected.to contain_class('agent_upgrade::config') }
          it { is_expected.to contain_class('agent_upgrade::service').that_subscribes_to('agent_upgrade::config') }

          it { is_expected.to contain_service('agent_upgrade') }
          it { is_expected.to contain_package('agent_upgrade').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'agent_upgrade class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('agent_upgrade') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
