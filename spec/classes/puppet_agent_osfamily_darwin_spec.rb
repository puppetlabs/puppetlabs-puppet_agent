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
    :is_pe                       => true,
    :osfamily                    => 'Darwin',
    :operatingsystem             => 'Darwin',
    :macosx_productversion_major => '10.9',
    :architecture                => 'x86_64',
    :servername                  => 'master.example.vm',
    :clientcert                  => 'foo.example.vm',
  }

  describe 'unsupported environment' do
    context "when OSX 10.8" do
      let(:facts) do
        facts.merge({
          :platform_tag                => "osx-10.8-x86_64",
          :macosx_productversion_major => '10.8',
        })
      end

      it { expect { catalogue }.to raise_error(/not supported/) }
    end
  end

  describe 'supported environment' do
    context "when OSX 10.9" do
      let(:facts) do
        facts.merge({
          :is_pe                       => true,
          :platform_tag                => "osx-10.9-x86_64",
          :macosx_productversion_major => '10.9',
        })
      end

      it { should compile.with_all_deps }
      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_package('puppet-agent').with_source('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.osx10.9.dmg') }
    end

    context "when OSX 10.10" do
      let(:facts) do
        facts.merge({
          :is_pe                       => true,
          :platform_tag                => "osx-10.10-x86_64",
          :macosx_productversion_major => '10.10',
        })
      end

      it { should compile.with_all_deps }
      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_package('puppet-agent').with_source('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.osx10.10.dmg') }
    end

    context "when OSX 10.11" do
      let(:facts) do
        facts.merge({
          :is_pe                       => true,
          :platform_tag                => "osx-10.11-x86_64",
          :macosx_productversion_major => '10.11',
        })
      end

      it { should compile.with_all_deps }
      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_package('puppet-agent').with_source('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.osx10.11.dmg') }
    end
  end
end
