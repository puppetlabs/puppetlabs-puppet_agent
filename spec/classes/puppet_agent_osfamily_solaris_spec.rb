require 'spec_helper'

describe 'puppet_agent' do
  facts = {
    :osfamily                  => 'Solaris',
    :operatingsystem           => 'Solaris',
    :operatingsystemmajrelease => '10',
    :architecture              => 'i86pc',
    :servername                => 'master.example.vm',
    :clientcert                => 'foo.example.vm',
  }

  package_version = '1.2.5.90.g93a35da'
  # Strips out strings in the version string on Solaris 11,
  # because pkg doesn't accept strings in version numbers. This
  # is how developer builds are labelled.
  sol11_package_version = '1.2.5.90.9335'
  pe_version = '2000.0.0'
  if Puppet.version >= "4.0.0"
    let(:params) do
      {
        :package_version => package_version
      }
    end
  end

  describe 'unsupported environment' do
    context 'when not PE' do
      let(:facts) do
        facts.merge({
          :is_pe => false,
        })
      end

      # FOSS requires the package_version because the pe_compiling_server_version
      # fact isn't available.
      let(:params) do
        {
          :package_version => package_version
        }
      end

      it { expect { catalogue }.to raise_error(/only supported on Puppet Enterprise/) }
    end
  end

  describe 'supported environment' do
    before(:each) do
      # Need to mock the PE functions
      Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
        pe_version
      end

      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
        package_version
      end

      # Ensure we get a versionable package provider
      pkg = Puppet::Type.type(:package)
      pkg.stubs(:defaultprovider).returns(pkg.provider(:pkg))
    end

    context "when Solaris 11 i386" do
      let(:facts) do
        facts.merge({
          :is_pe                     => true,
          :platform_tag              => "solaris-11-i386",
          :operatingsystemmajrelease => '11',
        })
      end

      it { should compile.with_all_deps }
      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_file('/opt/puppetlabs/packages') }
      it do
        is_expected.to contain_file("/opt/puppetlabs/packages/puppet-agent@#{sol11_package_version},5.11-1.i386.p5p").with({
          'ensure' => 'present',
          'source' => "puppet:///pe_packages/#{pe_version}/solaris-11-i386/puppet-agent@#{sol11_package_version},5.11-1.i386.p5p",
        })
      end

      context "when managing Solaris 11 i386 repo" do
        let(:params) {
          {
            :manage_repo => true,
            :package_version => package_version
          }
        }

        it do
          is_expected.to contain_exec('puppet_agent remove existing repo').with_command("rm -rf '/etc/puppetlabs/installer/solaris.repo'")
          is_expected.to contain_exec('puppet_agent create repo').with_command('pkgrepo create /etc/puppetlabs/installer/solaris.repo')
          is_expected.to contain_exec('puppet_agent set publisher').with_command('pkgrepo set -s /etc/puppetlabs/installer/solaris.repo publisher/prefix=puppetlabs.com')
          is_expected.to contain_exec('puppet_agent copy packages').with_command("pkgrecv -s file:///opt/puppetlabs/packages/puppet-agent@#{sol11_package_version},5.11-1.i386.p5p -d /etc/puppetlabs/installer/solaris.repo '*'")
          is_expected.to contain_exec('puppet_agent ensure pkgrepo is up-to-date').with_command('pkgrepo refresh -s /etc/puppetlabs/installer/solaris.repo')
        end
      end

      context "when not managing Solaris 11 i386 repo" do
        let(:params) {
          {
            :manage_repo => false,
            :package_version => package_version
          }
        }

        it do
          is_expected.not_to contain_exec('puppet_agent remove existing repo')
          is_expected.not_to contain_exec('puppet_agent create repo')
          is_expected.not_to contain_exec('puppet_agent set publisher')
          is_expected.not_to contain_exec('puppet_agent copy packages')
          is_expected.not_to contain_exec('puppet_agent ensure pkgrepo is up-to-date')
        end
      end

      if Puppet.version < "4.0.0"
        [
          'pe-augeas',
          'pe-deep-merge',
          'pe-facter',
          'pe-hiera',
          'pe-libldap',
          'pe-libyaml',
          'pe-mcollective',
          'pe-mcollective-common',
          'pe-openssl',
          'pe-puppet',
          'pe-puppet-enterprise-release',
          'pe-ruby',
          'pe-ruby-augeas',
          'pe-ruby-ldap',
          'pe-ruby-rgen',
          'pe-ruby-shadow',
          'pe-stomp',
          'pe-virt-what',
        ].each do |package|
          it do
            is_expected.to contain_package(package).with_ensure('absent')
          end
        end

        it do
          is_expected.to contain_exec('puppet_agent backup /etc/puppetlabs/').with({
            'command' => 'cp -r /etc/puppetlabs/ /tmp/puppet_agent/',
          })

          is_expected.to contain_package('puppet-agent').with_ensure('present')
        end
      else
        it do
          is_expected.not_to contain_transition("remove puppet-agent")
          is_expected.to contain_package('puppet-agent').with_ensure(sol11_package_version)
        end
      end
    end

    context "when Solaris 11 sparc sun4u" do
      let(:facts) do
        facts.merge({
          :is_pe                     => true,
          :platform_tag              => "solaris-11-sparc",
          :operatingsystemmajrelease => '11',
          :architecture              => 'sun4u',
        })
      end

      it { should compile.with_all_deps }
      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_file('/opt/puppetlabs/packages') }
      it do
        is_expected.to contain_file("/opt/puppetlabs/packages/puppet-agent@#{sol11_package_version},5.11-1.sparc.p5p").with({
          'ensure' => 'present',
          'source' => "puppet:///pe_packages/#{pe_version}/solaris-11-sparc/puppet-agent@#{sol11_package_version},5.11-1.sparc.p5p",
        })
      end

      context "when managing Solaris 11 sparc sun4u repo" do
        let(:params) {
          {
            :manage_repo => true,
            :package_version => package_version
          }
        }
        it do
          is_expected.to contain_exec('puppet_agent remove existing repo').with_command("rm -rf '/etc/puppetlabs/installer/solaris.repo'")
          is_expected.to contain_exec('puppet_agent create repo').with_command('pkgrepo create /etc/puppetlabs/installer/solaris.repo')
          is_expected.to contain_exec('puppet_agent set publisher').with_command('pkgrepo set -s /etc/puppetlabs/installer/solaris.repo publisher/prefix=puppetlabs.com')
          is_expected.to contain_exec('puppet_agent copy packages').with_command("pkgrecv -s file:///opt/puppetlabs/packages/puppet-agent@#{sol11_package_version},5.11-1.sparc.p5p -d /etc/puppetlabs/installer/solaris.repo '*'")
          is_expected.to contain_exec('puppet_agent ensure pkgrepo is up-to-date').with_command('pkgrepo refresh -s /etc/puppetlabs/installer/solaris.repo')
        end
      end

      context "when not managing Solaris 11 sparc sun4u repo" do
        let(:params) {
          {
            :manage_repo => false,
            :package_version => package_version
          }
        }

        it do
          is_expected.not_to contain_exec('puppet_agent remove existing repo')
          is_expected.not_to contain_exec('puppet_agent create repo')
          is_expected.not_to contain_exec('puppet_agent set publisher')
          is_expected.not_to contain_exec('puppet_agent copy packages')
          is_expected.not_to contain_exec('puppet_agent ensure pkgrepo is up-to-date')
        end

      end

      if Puppet.version < "4.0.0"
        [
          'pe-augeas',
          'pe-deep-merge',
          'pe-facter',
          'pe-hiera',
          'pe-libldap',
          'pe-libyaml',
          'pe-mcollective',
          'pe-mcollective-common',
          'pe-openssl',
          'pe-puppet',
          'pe-puppet-enterprise-release',
          'pe-ruby',
          'pe-ruby-augeas',
          'pe-ruby-ldap',
          'pe-ruby-rgen',
          'pe-ruby-shadow',
          'pe-stomp',
          'pe-virt-what',
        ].each do |package|
          it do
            is_expected.to contain_package(package).with_ensure('absent')
          end
        end

        it do
          is_expected.to contain_exec('puppet_agent backup /etc/puppetlabs/').with({
            'command' => 'cp -r /etc/puppetlabs/ /tmp/puppet_agent/',
          })

          is_expected.to contain_package('puppet-agent').with_ensure('present')
        end
      else
        it do
          is_expected.not_to contain_transition("remove puppet-agent")
          is_expected.to contain_package('puppet-agent').with_ensure(sol11_package_version)
        end
      end
    end

    context "when Solaris 10 i386" do
      let(:facts) do
        facts.merge({
          :is_pe                     => true,
          :platform_tag              => "solaris-10-i386",
          :operatingsystemmajrelease => '10',
        })
      end
      it { should compile.with_all_deps }

      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_file('/opt/puppetlabs/packages') }
      it do
        is_expected.to contain_file("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.i386.pkg.gz").with({
          'ensure' => 'present',
          'source' => "puppet:///pe_packages/#{pe_version}/solaris-10-i386/puppet-agent-#{package_version}-1.i386.pkg.gz"
        })
      end

      it { is_expected.to contain_file('/opt/puppetlabs/packages/solaris-noask').with_source("puppet:///pe_packages/#{pe_version}/solaris-10-i386/solaris-noask") }
      it do
        is_expected.to contain_exec("unzip puppet-agent-#{package_version}-1.i386.pkg.gz").with_command("gzip -d /opt/puppetlabs/packages/puppet-agent-#{package_version}-1.i386.pkg.gz")
        is_expected.to contain_exec("unzip puppet-agent-#{package_version}-1.i386.pkg.gz").with_creates("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.i386.pkg")
      end

      it { is_expected.to contain_class('puppet_agent::install::remove_packages') }
      it { is_expected.to contain_class("puppet_agent::osfamily::solaris") }

      if Puppet.version < "4.0.0"
        it { is_expected.to contain_service('pe-puppet').with_ensure('stopped') }
        it { is_expected.to contain_service('pe-mcollective').with_ensure('stopped') }

        [
          'PUPpuppet',
          'PUPaugeas',
          'PUPdeep-merge',
          'PUPfacter',
          'PUPhiera',
          'PUPlibyaml',
          'PUPmcollective',
          'PUPopenssl',
          'PUPpuppet-enterprise-release',
          'PUPruby',
          'PUPruby-augeas',
          'PUPruby-rgen',
          'PUPruby-shadow',
          'PUPstomp',
        ].each do |package|
          it do
            is_expected.to contain_package(package).with_ensure('absent')
            is_expected.to contain_package(package).with_adminfile('/opt/puppetlabs/packages/solaris-noask')
          end
        end
      else
        context 'with older aio_agent_version' do
          let(:facts) do
            facts.merge({
              :is_pe                     => true,
              :platform_tag              => "solaris-10-i386",
              :operatingsystemmajrelease => '10',
              :aio_agent_version         => '1.0.0',
            })
          end

          it do
            is_expected.to contain_transition("remove puppet-agent").with(
              :attributes => {
                'ensure' => 'absent',
                'adminfile' => '/opt/puppetlabs/packages/solaris-noask',
              })
          end
        end

        context 'with up-to-date aio_agent_version' do
          let(:facts) do
            facts.merge({
              :is_pe                     => true,
              :platform_tag              => "solaris-10-i386",
              :operatingsystemmajrelease => '10',
              :aio_agent_version         => package_version,
            })
          end

          it { is_expected.not_to contain_transition("remove puppet-agent") }
        end

        context 'with up-to-date aio_agent_version missing git sha' do
          let(:facts) do
            facts.merge({
              :is_pe                     => true,
              :platform_tag              => "solaris-10-i386",
              :operatingsystemmajrelease => '10',
              :aio_agent_version         => '1.2.5.90',
            })
          end

          it { is_expected.not_to contain_transition("remove puppet-agent") }
        end
      end

      it do
        is_expected.to contain_package('puppet-agent').with_adminfile('/opt/puppetlabs/packages/solaris-noask')
        is_expected.to contain_package('puppet-agent').with_ensure('present')
        is_expected.to contain_package('puppet-agent').with_source("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.i386.pkg")
        is_expected.to contain_package('puppet-agent').with_install_options('-G')
      end
    end

    context "when Solaris 10 sparc sun4u" do
      before(:each) do
        # Need to mock the PE functions
        Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
          pe_version
        end

        Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
          package_version
        end
      end

      let(:facts) do
        facts.merge({
          :is_pe                     => true,
          :platform_tag              => "solaris-10-sparc",
          :operatingsystemmajrelease => '10',
          :architecture              => 'sun4u',
        })
      end

      it { should compile.with_all_deps }

      it { is_expected.to contain_file('/opt/puppetlabs/packages') }
      it do
        is_expected.to contain_file("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.sparc.pkg.gz").with({
          'ensure' => 'present',
          'source' => "puppet:///pe_packages/#{pe_version}/solaris-10-sparc/puppet-agent-#{package_version}-1.sparc.pkg.gz"
        })
      end

      it { is_expected.to contain_file('/opt/puppetlabs/packages/solaris-noask').with_source("puppet:///pe_packages/#{pe_version}/solaris-10-sparc/solaris-noask") }
      it do
        is_expected.to contain_exec("unzip puppet-agent-#{package_version}-1.sparc.pkg.gz").with_command("gzip -d /opt/puppetlabs/packages/puppet-agent-#{package_version}-1.sparc.pkg.gz")
        is_expected.to contain_exec("unzip puppet-agent-#{package_version}-1.sparc.pkg.gz").with_creates("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.sparc.pkg")
      end

      it { is_expected.to contain_class('puppet_agent::install::remove_packages') }
      it { is_expected.to contain_class("puppet_agent::osfamily::solaris") }

      if Puppet.version < "4.0.0"
        it { is_expected.to contain_service('pe-puppet').with_ensure('stopped') }
        it { is_expected.to contain_service('pe-mcollective').with_ensure('stopped') }

        [
          'PUPpuppet',
          'PUPaugeas',
          'PUPdeep-merge',
          'PUPfacter',
          'PUPhiera',
          'PUPlibyaml',
          'PUPmcollective',
          'PUPopenssl',
          'PUPpuppet-enterprise-release',
          'PUPruby',
          'PUPruby-augeas',
          'PUPruby-rgen',
          'PUPruby-shadow',
          'PUPstomp',
        ].each do |package|
          it do
            is_expected.to contain_package(package).with_ensure('absent')
            is_expected.to contain_package(package).with_adminfile('/opt/puppetlabs/packages/solaris-noask')
          end
        end
      else
        context 'aio_agent_version is out of date' do
          let(:facts) do
            facts.merge({
              :is_pe                     => true,
              :platform_tag              => "solaris-10-sparc",
              :operatingsystemmajrelease => '10',
              :architecture              => 'sun4u',
              :aio_agent_version         => '1.0.0'
            })
          end

          it do
            is_expected.to contain_transition("remove puppet-agent").with(
              :attributes => {
                'ensure' => 'absent',
                'adminfile' => '/opt/puppetlabs/packages/solaris-noask',
              })
          end
        end

        it { is_expected.not_to contain_transition("remove puppet-agent") }
      end

      it do
        is_expected.to contain_package('puppet-agent').with_adminfile('/opt/puppetlabs/packages/solaris-noask')
        is_expected.to contain_package('puppet-agent').with_ensure('present')
        is_expected.to contain_package('puppet-agent').with_source("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.sparc.pkg")
        is_expected.to contain_package('puppet-agent').with_install_options('-G')
      end
    end
  end
end
