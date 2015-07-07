require 'spec_helper'

describe 'puppet_agent', :unless => Puppet.version < "3.8.0" || Puppet.version >= "4.0.0" do
  before(:each) do
    # Need to mock the function pe_build_version
    pe_build_version = {}

    Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) {
      |args| pe_build_version.call()
    }

    pe_build_version.stubs(:call).returns('4.0.0')
  end

  facts = {
    :is_pe                     => true,
    :osfamily                  => 'Suse',
    :operatingsystem           => 'SLES',
    :operatingsystemmajrelease => '12',
    :architecture              => 'x64',
    :servername                => 'master.example.vm',
    :clientcert                => 'foo.example.vm',
  }

  describe 'unsupported environment' do
    context 'when not PE' do
      let(:facts) do
        facts.merge({
          :is_pe => false,
        })
      end

      it { should compile.and_raise_error(/SLES not supported/) }
    end

    context 'when not SLES' do
      let(:facts) do
        facts.merge({
          :is_pe           => false,
          :operatingsystem => 'OpenSuse',
        })
      end

      it { should compile.and_raise_error(/OpenSuse not supported/) }
    end

    context "when operatingsystemmajrelease is not supported" do
      ['10', '11'].each do |os_version|
        context "when SLES #{os_version}" do
          let(:facts) do
            facts.merge({
              :is_pe                     => true,
              :osfamily                  => 'Suse',
              :operatingsystem           => 'SLES',
              :operatingsystemmajrelease => os_version
            })
          end

          it { should compile.and_raise_error(/SLES #{os_version} not supported/) }
        end
      end
    end
  end

  describe 'supported environment' do
    context "when operatingsystemmajrelease is supported" do
      ['12'].each do |os_version|
        context "when SLES #{os_version}" do
          let(:facts) do
            facts.merge({
              :operatingsystemmajrelease => os_version,
              :platform_tag              => "sles-#{os_version}-x86_64",
            })
          end

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

          {
            'name'        => 'pc1_repo',
            'enabled'      => '1',
            'autorefresh' => '0',
            'baseurl'     => "https://master.example.vm:8140/packages/4.0.0/sles-#{os_version}-x86_64?ssl_verify=no",
            'type'        => 'rpm-md',
          }.each do |setting, value|
              it { is_expected.to contain_ini_setting("zypper pc1_repo #{setting}").with({
                'path'    => '/etc/zypp/repos.d/pc1_repo.repo',
                'section' => 'pc1_repo',
                'setting' => setting,
                'value'   => value,
              }) }
            end
        end
      end
    end
  end
end
