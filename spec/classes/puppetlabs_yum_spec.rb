require 'spec_helper'

describe 'agent_upgrade::puppetlabs_yum' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { is_expected.to contain_agent_upgrade__rpm_gpg_key('RPM-GPG-KEY-puppetlabs').with({
          'path'  => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
        }) }
        it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs').with({
          'ensure' => 'present',
          'owner'  => '0',
          'group'  => '0',
          'mode'   => '0644',
          'source' => 'puppet:///modules/agent_upgrade/RPM-GPG-KEY-puppetlabs',
        }) }
      end
    end
  end
end
