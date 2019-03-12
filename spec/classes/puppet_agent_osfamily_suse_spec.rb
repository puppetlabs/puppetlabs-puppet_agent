require 'spec_helper'

describe 'puppet_agent' do
  package_version = '1.10.100'
  before(:each) do
    # Need to mock the PE functions
    Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
      "2000.0.0"
    end

    Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
      package_version
    end
  end

  facts = {
    :is_pe                     => true,
    :osfamily                  => 'Suse',
    :operatingsystem           => 'SLES',
    :operatingsystemmajrelease => '12',
    :architecture              => 'x64',
    :puppet_master_server      => 'master.example.vm',
    :clientcert                => 'foo.example.vm',
  }

  let(:params) do
    {
      :package_version => package_version
    }
  end

  describe 'unsupported environment' do
    context 'when not SLES' do
      let(:facts) do
        facts.merge({
          :operatingsystem => 'OpenSuse',
        })
      end

      it { expect { catalogue }.to raise_error(/OpenSuse not supported/) }
    end
  end

  describe 'supported environment' do
    context "when operatingsystemmajrelease 11 or 12 is supported" do
      ['11', '12'].each do |os_version|
        context "when SLES #{os_version}" do
          let(:facts) do
            facts.merge({
              :operatingsystemmajrelease => os_version,
              :platform_tag              => "sles-#{os_version}-x86_64",
            })
          end

          it { is_expected.to contain_exec('import-GPG-KEY-puppet').with({
            'path'      => '/bin:/usr/bin:/sbin:/usr/sbin',
            'command'   => 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet',
            'unless'    => "rpm -q gpg-pubkey-$(echo $(gpg --homedir /root/.gnupg --with-colons /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet 2>&1 | grep ^pub | awk -F ':' '{print \$5}' | cut --characters=9-16 | tr '[:upper:]' '[:lower:]'))",
            'require'   => 'File[/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet]',
            'logoutput' => 'on_failure',
          }) }

          it { is_expected.to contain_exec('import-GPG-KEY-puppetlabs').with({
            'path'      => '/bin:/usr/bin:/sbin:/usr/sbin',
            'command'   => 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
            'unless'    => "rpm -q gpg-pubkey-$(echo $(gpg --homedir /root/.gnupg --with-colons /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs 2>&1 | grep ^pub | awk -F ':' '{print \$5}' | cut --characters=9-16 | tr '[:upper:]' '[:lower:]'))",
            'require'   => 'File[/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs]',
            'logoutput' => 'on_failure',
          }) }

          context 'with manage_pki_dir => true' do
            ['/etc/pki', '/etc/pki/rpm-gpg'].each do |path|
              it { is_expected.to contain_file(path).with({
                'ensure' => 'directory',
              }) }
            end
          end

          context 'with manage_pki_dir => false' do
            let(:params) {{ :manage_pki_dir => 'false' }}
            ['/etc/pki', '/etc/pki/rpm-gpg'].each do |path|
              it { is_expected.not_to contain_file(path) }
            end
          end

          it { is_expected.to contain_class("puppet_agent::osfamily::suse") }

          it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs').with({
            'ensure' => 'present',
            'owner'  => '0',
            'group'  => '0',
            'mode'   => '0644',
            'source' => 'puppet:///modules/puppet_agent/GPG-KEY-puppetlabs',
          }) }

          it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet').with({
            'ensure' => 'present',
            'owner'  => '0',
            'group'  => '0',
            'mode'   => '0644',
            'source' => 'puppet:///modules/puppet_agent/GPG-KEY-puppet',
          }) }

          context "with manage_repo enabled" do
            let(:params) {
              {
                :manage_repo => true,
                :package_version => package_version
              }
            }

            {
              'name'        => 'pc_repo',
              'enabled'     => '1',
              'autorefresh' => '0',
              'baseurl'     => "https://master.example.vm:8140/packages/2000.0.0/sles-#{os_version}-x86_64?ssl_verify=no",
              'type'        => 'rpm-md',
            }.each do |setting, value|
              it { is_expected.to contain_ini_setting("zypper pc_repo #{setting}").with({
                'path'    => '/etc/zypp/repos.d/pc_repo.repo',
                'section' => 'pc_repo',
                'setting' => setting,
                'value'   => value,
              }) }
            end
          end

          context "with manage_repo disabled" do
            let(:params) {
              {
                :manage_repo => false,
                :package_version => package_version
              }
            }

            [
              'name',
              'enabled',
              'autorefresh',
              'baseurl',
              'type',
            ].each do |setting|
              it { is_expected.not_to contain_ini_setting("zypper pc_repo #{setting}") }
            end
          end

          context "with manage_repo enabled and custom source" do
            let(:params) {
              {
                :manage_repo => true,
                :package_version => package_version,
                :source => "https://fake-sles-source.com",
              }
            }
            it { is_expected.to contain_ini_setting("zypper pc_repo baseurl").with({
              'path'    => '/etc/zypp/repos.d/pc_repo.repo',
              'section' => 'pc_repo',
              'setting' => 'baseurl',
              'value'   => "https://fake-sles-source.com/packages/2000.0.0/sles-#{os_version}-x86_64?ssl_verify=no",
            }) }
          end

          it do
            is_expected.to contain_package('puppet-agent')
          end
        end
      end
    end
  end
end
