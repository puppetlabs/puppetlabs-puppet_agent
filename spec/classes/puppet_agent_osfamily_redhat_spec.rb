require 'spec_helper'

describe 'puppet_agent' do
  # All FOSS and all Puppet 4+ upgrades require the package_version
  package_version = '5.5.4'
  let(:params) {
    {
      :package_version => package_version
    }
  }

  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :architecture              => 'x64',
      :puppet_master_server      => 'master.example.vm',
      :clientcert                => 'foo.example.vm',
      :env_temp_variable         => '/tmp',
    }
  end

  [['Rocky', 'el/8', 8], ['AlmaLinux', 'el/8', 8], ['Fedora', 'fedora/f34', 34], ['CentOS', 'el/7', 7], ['Amazon', 'el/6', 2017], ['Amazon', 'el/7', 2]].each do |os, urlbit, osmajor|
    context "with #{os} and #{urlbit}" do
      let(:facts) do
        super().merge(:operatingsystem  => os, :operatingsystemmajrelease => osmajor)
      end
      script = <<-SCRIPT
ACTION=$0
GPG_HOMEDIR=$1
GPG_KEY_PATH=$2
GPG_ARGS="--homedir $GPG_HOMEDIR --with-colons"
GPG_BIN=$(command -v gpg || command -v gpg2)
if [ -z "${GPG_BIN}" ]; then
  echo Could not find a suitable gpg command, exiting...
  exit 1
fi
GPG_PUBKEY=gpg-pubkey-$("${GPG_BIN}" ${GPG_ARGS} "${GPG_KEY_PATH}" 2>&1 | grep ^pub | cut -d: -f5 | cut --characters=9-16 | tr "[:upper:]" "[:lower:]")
if [ "${ACTION}" = "check" ]; then
  # This will return 1 if there are differences between the key imported in the
  # RPM database and the local keyfile. This means we need to purge the key and
  # reimport it.
  diff <(rpm -qi "${GPG_PUBKEY}" | "${GPG_BIN}" ${GPG_ARGS}) <("${GPG_BIN}" ${GPG_ARGS} "${GPG_KEY_PATH}")
elif [ "${ACTION}" = "import" ]; then
  (rpm -q "${GPG_PUBKEY}" && rpm -e --allmatches "${GPG_PUBKEY}") || true
  rpm --import "${GPG_KEY_PATH}"
fi
SCRIPT

      it { is_expected.to contain_exec('import-GPG-KEY-puppet-20250406').with({
        'path'      => '/bin:/usr/bin:/sbin:/usr/sbin',
        'command'   => "/bin/bash -c '#{script}' import /root/.gnupg /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
        'unless'    => "/bin/bash -c '#{script}' check /root/.gnupg /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
        'require'   => 'File[/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406]',
        'logoutput' => 'on_failure',
      }) }

      it { is_expected.to contain_exec('import-GPG-KEY-puppet').with({
        'path'      => '/bin:/usr/bin:/sbin:/usr/sbin',
        'command'   => "/bin/bash -c '#{script}' import /root/.gnupg /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet",
        'unless'    => "/bin/bash -c '#{script}' check /root/.gnupg /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet",
        'require'   => 'File[/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet]',
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

      it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406').with({
        'ensure' => 'present',
        'owner'  => '0',
        'group'  => '0',
        'mode'   => '0644',
        'source' => 'puppet:///modules/puppet_agent/GPG-KEY-puppet-20250406',
      }) }

      it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet').with({
        'ensure' => 'present',
        'owner'  => '0',
        'group'  => '0',
        'mode'   => '0644',
        'source' => 'puppet:///modules/puppet_agent/GPG-KEY-puppet',
      }) }

      context 'when FOSS and manage_repo disabled' do
        let(:params)  {
          {
            :manage_repo => false,
            :package_version => package_version
          }
        }
        it { is_expected.not_to contain_yumrepo('puppetlabs-pepackages').with_ensure('absent') }
        it { is_expected.not_to contain_yumrepo('pc_repo')}

        it { is_expected.to contain_class("puppet_agent::osfamily::redhat") }
      end

      context 'when installing a puppet5 project' do
        let(:params)  {
          {
            :package_version => '5.2.0',
            :collection => 'puppet5'
          }
        }
        it { is_expected.to contain_yumrepo('pc_repo').with({
          # We no longer expect the 'f' in fedora repos
          'baseurl' => "http://yum.puppet.com/puppet5/#{urlbit.gsub('/f','/')}/x64",
          'enabled' => 'true',
            'gpgcheck' => '1',
            'gpgkey' => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet\n  file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
        }) }
      end

      context 'when using a custom source' do
        let(:params)  {
          {
            :package_version => '5.2.0',
            :collection => 'puppet5',
            :yum_source => "http://fake-yum.com"
          }
        }
        it { is_expected.to contain_yumrepo('pc_repo').with_baseurl("http://fake-yum.com/puppet5/#{urlbit.gsub('/f','/')}/x64") }
      end
    end
  end

  [['RedHat', 'el-7-x86_64', 'el-7-x86_64', 7], ['RedHat', 'el-8-x86_64', 'el-8-x86_64', 8], ['Amazon', '', 'el-6-x64', 6]].each do |os, tag, repodir, osmajor|
    context "when PE on #{os}" do
      before(:each) do
        # Need to mock the PE functions

        Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
          '2000.0.0'
        end

        Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
          '5.5.4'
        end
      end

      let(:facts) do
        super().merge(
          :operatingsystem  => os,
          :operatingsystemmajrelease => osmajor,
          :platform_tag => tag,
          is_pe: true
        )
      end

      context 'when using a custom source' do
        let(:params)  {
          {
            :package_version => '5.2.0',
            :manage_repo => true,
            :source => "http://fake-pe-master.com"
          }
        }
        it { is_expected.to contain_yumrepo('pc_repo').with_baseurl("http://fake-pe-master.com/packages/2000.0.0/#{repodir}") }
      end

      context 'with manage_repo enabled' do
        let(:params)  {
          {
            :manage_repo => true,
            :package_version => package_version
          }
        }

        it { is_expected.to contain_yumrepo('puppetlabs-pepackages').with_ensure('absent') }

        it { is_expected.to contain_yumrepo('pc_repo').with({
          'baseurl' => "https://master.example.vm:8140/packages/2000.0.0/#{repodir}",
          'enabled' => 'true',
          'gpgcheck' => '1',
          'gpgkey' => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet\n  file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
          'sslcacert' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
          'sslclientcert' => '/etc/puppetlabs/puppet/ssl/certs/foo.example.vm.pem',
          'sslclientkey' => '/etc/puppetlabs/puppet/ssl/private_keys/foo.example.vm.pem',
          'skip_if_unavailable' => 'absent',
        }) }
        describe 'disable proxy' do
          let(:params) {
            {
              :manage_repo => true,
              :package_version => package_version,
              :disable_proxy   => true,
            }
          }
          it {
            is_expected.to contain_yumrepo('pc_repo').with_proxy('_none_')
          }
        end
        describe 'proxy' do
          let(:params) {
            {
              :manage_repo     => true,
              :package_version => package_version,
              :proxy           => 'http://myrepo-proxy.example.com',
            }
          }
          it {
            is_expected.to contain_yumrepo('pc_repo').with_proxy('http://myrepo-proxy.example.com')
          }
        end
        describe 'skip repo if unavailable' do
          let(:params) {
            {
              :manage_repo => true,
              :package_version => package_version,
              :skip_if_unavailable => true,
            }
          }
          it {
            is_expected.to contain_yumrepo('pc_repo').with_skip_if_unavailable(true)
          }
        end
      end

      context 'with manage_repo disabled' do
        let(:params)  {
          {
            :manage_repo => false,
            :package_version => package_version
          }
        }

        it { is_expected.to contain_yumrepo('puppetlabs-pepackages').with_ensure('absent') }

        it { is_expected.not_to contain_yumrepo('pc_repo')}
      end

      context 'with explicit package version' do
        let(:params)  {
          {
            :manage_repo => false,
            :package_version => package_version
          }
        }
        it { is_expected.to contain_package('puppet-agent').with_ensure("#{params[:package_version]}") }

      end

      it { is_expected.to contain_class("puppet_agent::osfamily::redhat") }
    end

    context 'when using absolute_source' do
      let(:params)  {
        {
          :package_version => '6.12.0',
          :absolute_source => "http://just-some-download/url:90/puppet-agent-6.12.0.rpm"
        }
      }

      it { is_expected.to contain_class('Puppet_agent::Prepare::Package')
        .with('source' => 'http://just-some-download/url:90/puppet-agent-6.12.0.rpm')
      }

      it { is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-6.12.0.rpm')
        .with('path'     => '/opt/puppetlabs/packages/puppet-agent-6.12.0.rpm')
        .with('ensure'   => 'present')
        .with('owner'    => '0')
        .with('group'    => '0')
        .with('mode'     => '0644')
        .with('source'   => 'http://just-some-download/url:90/puppet-agent-6.12.0.rpm')
        .that_requires('File[/opt/puppetlabs/packages]')
        .with('checksum' => 'sha256lite')
      }

      it { is_expected.to contain_package('puppet-agent')
        .with('ensure'          => '6.12.0')
        .with('install_options' => '[]')
        .with('provider'        => 'rpm')
        .with('source'          => '/opt/puppetlabs/packages/puppet-agent-6.12.0.rpm')
      }
      
    end

  end
end
