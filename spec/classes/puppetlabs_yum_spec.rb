require 'spec_helper'

describe 'agent_upgrade::puppetlabs_yum' do
  context 'on RedHat' do
    [['Fedora', 'fedora/f$releasever'], ['foo', 'el/$releasever']].each do |os, urlbit|
      context "with #{os} and #{urlbit}" do
        let(:facts) {{
          :osfamily => 'RedHat',
          :operatingsystem => os,
          :architecture => 'foo',
        }}

        it { is_expected.to contain_agent_upgrade__rpm_gpg_key('RPM-GPG-KEY-puppetlabs').with({
          'path'  => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
        }) }

        ['/etc/pki', '/etc/pki/rpm-gpg'].each do |path|
          it { is_expected.to contain_file(path).with({
            'ensure' => 'directory',
          }) }
        end

        it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs').with({
          'ensure' => 'present',
          'owner'  => '0',
          'group'  => '0',
          'mode'   => '0644',
          'source' => 'puppet:///modules/agent_upgrade/RPM-GPG-KEY-puppetlabs',
        }) }

        it { is_expected.to contain_yumrepo('pc1_repo').with({
          'baseurl' => "https://yum.puppetlabs.com/#{urlbit}/PC1/foo",
          'enabled' => 'true',
          'gpgcheck' => '1',
          'gpgkey' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
        }) }
      end
    end
  end
end
