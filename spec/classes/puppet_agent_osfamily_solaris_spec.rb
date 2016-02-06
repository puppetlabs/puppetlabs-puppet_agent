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
    :osfamily                  => 'Solaris',
    :operatingsystem           => 'Solaris',
    :operatingsystemmajrelease => '10',
    :architecture              => 'i86pc',
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

      it { expect { catalogue }.to raise_error(/Solaris not supported/) }
    end
  end

  describe 'not yet supported releases' do
    context 'when Solaris 11' do
      let(:facts) do
        facts.merge({
          :is_pe => true,
          :operatingsystemmajrelease => '11',
        })
      end

      it { expect { catalogue }.to raise_error(/Solaris 11 not supported/) }
    end
  end

  describe 'supported environment' do
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
        is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.i386.pkg.gz').with_ensure('present')
        is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.i386.pkg.gz').with_source('puppet:///pe_packages/4.0.0/solaris-10-i386/puppet-agent-1.2.5-1.i386.pkg.gz')
      end

      it { is_expected.to contain_file('/opt/puppetlabs/packages/solaris-noask').with_source('puppet:///pe_packages/4.0.0/solaris-10-i386/solaris-noask') }
      it do
        is_expected.to contain_exec('unzip puppet-agent-1.2.5-1.i386.pkg.gz').with_command('gzip -d /opt/puppetlabs/packages/puppet-agent-1.2.5-1.i386.pkg.gz')
        is_expected.to contain_exec('unzip puppet-agent-1.2.5-1.i386.pkg.gz').with_creates('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.i386.pkg')
      end

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

      it do
        is_expected.to contain_package('puppet-agent').with_adminfile('/opt/puppetlabs/packages/solaris-noask')
        is_expected.to contain_package('puppet-agent').with_source('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.i386.pkg')
      end
    end

    context "when Solaris 10 sparc sun4u" do
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
        is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.sparc.pkg.gz').with_ensure('present')
        is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.sparc.pkg.gz').with_source('puppet:///pe_packages/4.0.0/solaris-10-sparc/puppet-agent-1.2.5-1.sparc.pkg.gz')
      end

      it { is_expected.to contain_file('/opt/puppetlabs/packages/solaris-noask').with_source('puppet:///pe_packages/4.0.0/solaris-10-sparc/solaris-noask') }
      it do
        is_expected.to contain_exec('unzip puppet-agent-1.2.5-1.sparc.pkg.gz').with_command('gzip -d /opt/puppetlabs/packages/puppet-agent-1.2.5-1.sparc.pkg.gz')
        is_expected.to contain_exec('unzip puppet-agent-1.2.5-1.sparc.pkg.gz').with_creates('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.sparc.pkg')
      end

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

      it do
        is_expected.to contain_package('puppet-agent').with_adminfile('/opt/puppetlabs/packages/solaris-noask')
        is_expected.to contain_package('puppet-agent').with_source('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.sparc.pkg')
      end
    end
  end
end
