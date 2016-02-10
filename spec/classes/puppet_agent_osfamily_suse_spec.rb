require 'spec_helper'

describe 'puppet_agent', :unless => Puppet.version < "3.8.0" || Puppet.version >= "4.0.0" do
  before(:each) do
    # Need to mock the PE functions
    Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
      "4.0.0"
    end

    Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
      '1.2.5'
    end
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

      it { expect { catalogue }.to raise_error(/SLES not supported/) }
    end

    context 'when not SLES' do
      let(:facts) do
        facts.merge({
          :is_pe           => false,
          :operatingsystem => 'OpenSuse',
        })
      end

      it { expect { catalogue }.to raise_error(/OpenSuse not supported/) }
    end
  end

  describe 'supported environment' do
    context "when operatingsystemmajrelease 10 is supported" do
      let(:facts) do
        facts.merge({
          :operatingsystemmajrelease => '10',
          :platform_tag              => "sles-10-x86_64",
          :architecture              => "x86_64",
        })
      end

      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_file('/opt/puppetlabs/packages') }
      it do
        is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.sles10.x86_64.rpm').with_ensure('present')
        is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.sles10.x86_64.rpm').with_source('puppet:///pe_packages/4.0.0/sles-10-x86_64/puppet-agent-1.2.5-1.sles10.x86_64.rpm')
      end

      [
        'pe-augeas',
        'pe-mcollective-common',
        'pe-rubygem-deep-merge',
        'pe-mcollective',
        'pe-puppet-enterprise-release',
        'pe-libldap',
        'pe-libyaml',
        'pe-ruby-stomp',
        'pe-ruby-augeas',
        'pe-ruby-shadow',
        'pe-hiera',
        'pe-facter',
        'pe-puppet',
        'pe-openssl',
        'pe-ruby',
        'pe-ruby-rgen',
        'pe-virt-what',
        'pe-ruby-ldap',
      ].each do |package|
        it do
          is_expected.to contain_package(package).with_ensure('absent')
          is_expected.to contain_package(package).with_uninstall_options('--nodeps')
          is_expected.to contain_package(package).with_provider('rpm')
        end
      end

      it do
        is_expected.to contain_exec('replace puppet.conf removed by package removal').with_command('cp /etc/puppetlabs/puppet/puppet.conf.rpmsave /etc/puppetlabs/puppet/puppet.conf')
        is_expected.to contain_exec('replace puppet.conf removed by package removal').with_creates('/etc/puppetlabs/puppet/puppet.conf')
      end

      it do
        is_expected.to contain_package('puppet-agent').with_ensure('present')
        is_expected.to contain_package('puppet-agent').with_provider('rpm')
        is_expected.to contain_package('puppet-agent').with_source('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.sles10.x86_64.rpm')
      end
    end

    context "when operatingsystemmajrelease 11 or 12 is supported" do
      ['11', '12'].each do |os_version|
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
            'unless'    => 'rpm -q gpg-pubkey-$(echo $(gpg --homedir /root/.gnupg --throw-keyids < /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs) | cut --characters=11-18 | tr [A-Z] [a-z])',
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

          it do
            is_expected.to contain_package('puppet-agent')
          end
        end
      end
    end
  end
end
