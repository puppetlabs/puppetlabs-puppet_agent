require 'spec_helper'

describe 'puppet_agent::osfamily::redhat' do
  [['Fedora', 'fedora/f$releasever'], ['CentOS', 'el/$releasever']].each do |os, urlbit|
    context "with #{os} and #{urlbit}" do
      let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystem => os,
        :architecture => 'foo',
      }}

      it { is_expected.to contain_exec('import-RPM-GPG-KEY-puppetlabs').with({
        'path'      => '/bin:/usr/bin:/sbin:/usr/sbin',
        'command'   => 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
        'unless'    => 'rpm -q gpg-pubkey-`echo $(gpg --throw-keyids < /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs) | cut --characters=11-18 | tr [A-Z] [a-z]`',
        'require'   => 'File[/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs]',
        'logoutput' => 'on_failure',
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
        'source' => 'puppet:///modules/puppet_agent/RPM-GPG-KEY-puppetlabs',
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
