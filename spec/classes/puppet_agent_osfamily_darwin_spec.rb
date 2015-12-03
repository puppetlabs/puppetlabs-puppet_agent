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
    context 'when not PE' do
      let(:facts) do
        facts.merge({
          :is_pe => false,
        })
      end

      it { expect { catalogue }.to raise_error(/Darwin not supported/) }
    end
  end

  describe 'not yet supported releases' do
    context 'when OSX 10.10' do
      let(:facts) do
        facts.merge({
          :is_pe => true,
          :osx_productversion_major => '10.10',
        })
      end

      it { expect { catalogue }.to raise_error(/Darwin 10\.10 not supported/) }
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
      it { is_expected.to contain_package('puppet-agent').with_source('/opt/puppetlabs/packages/puppet-agent-1.2.5-1.osx10.9.dmg') }
    end
  end
end
