require 'spec_helper'

describe 'puppet_agent' do
  let(:common_facts) {
    {
      architecture:               'PowerPC_POWER7',
      clientcert:                 'foo.example.vm',
      is_pe:                      true,
      operatingsystem:            'AIX',
      osfamily:                   'AIX',
      platform_tag:               'aix-7.2-power',
      servername:                 'master.example.vm',
    }
  }

  shared_examples 'aix' do |aixver, pkg_aixver, powerver|
    let(:rpmname) {"puppet-agent-#{params[:package_version]}-1.aix#{pkg_aixver}.ppc.rpm"}
    let(:tag) { "aix-#{pkg_aixver}-power" }
    let(:source) { "puppet:///pe_packages/2000.0.0/#{tag}/#{rpmname}" }
    let(:facts) {
      common_facts.merge({
        architecture: "PowerPC_POWER#{powerver}",
        platform_tag: "aix-#{aixver}-power",
      })
    }

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2000.0.0' }
      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) { |_args| '1.10.100' }
    end

    it { is_expected.to contain_file('/opt/puppetlabs') }
    it { is_expected.to contain_file('/opt/puppetlabs/packages') }
    it { is_expected.to contain_file("/opt/puppetlabs/packages/#{rpmname}").with({ 'source' => source })
    }

    it { is_expected.to contain_class("puppet_agent::osfamily::aix") }

    it { is_expected.to contain_class('Puppet_agent::Install') }

    it {
      is_expected.to contain_package('puppet-agent').with({
        'source'    => "/opt/puppetlabs/packages/#{rpmname}",
        'ensure'    => params[:package_version],
        'provider'  => 'rpm',
      })
    }
  end

  context 'with a user specified source' do
    let(:facts) {
      common_facts.merge({
        architecture: "PowerPC_POWER8",
        platform_tag: "aix-6.1-power",
      })
    }
    let(:params) {
      {
        package_version: '5.10.100.1',
        collection: 'puppet5',
        source: 'https://fake-pe-master.com',
      }
    }
    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2000.0.0' }
      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) { |_args| '1.10.100' }
    end

    it {
      is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-5.10.100.1-1.aix6.1.ppc.rpm').with_source("https://fake-pe-master.com/packages/2000.0.0/aix-6.1-power/puppet-agent-5.10.100.1-1.aix6.1.ppc.rpm")
    }
  end

  context 'with a PC1 collection' do
    let(:params) {
      {
        package_version: '1.10.100',
        collection: 'PC1',
      }
    }

    [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '6.1', '7']].each do |aixver, pkg_aixver, powerver|
      context "aix #{aixver}" do
        include_examples 'aix', aixver, pkg_aixver, powerver
      end
    end
  end

  context 'with a puppet5 collection' do
    let(:params) {
      {
        package_version: '5.4.3',
        collection: 'puppet5',
      }
    }

    [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '6.1', '7']].each do |aixver, pkg_aixver, powerver|
      context "aix #{aixver}" do
        include_examples 'aix', aixver, pkg_aixver, powerver
      end
    end
  end

  context 'with a puppet6 collection' do
    let(:params) {
      {
        package_version: '6.0.0',
        collection: 'puppet6',
      }
    }

    [['7.2', '6.1', '8'], ['7.1', '6.1', '8'], ['7.1', '6.1', '7'], ['6.1', '6.1', '7']].each do |aixver, pkg_aixver, powerver|
      context "aix #{aixver}" do
        include_examples 'aix', aixver, pkg_aixver, powerver
      end
    end
  end

  context 'unsupported environments' do
    let(:params) {
      {
          package_version: '6.0.0',
          collection: 'puppet6'
      }
    }

    context 'not AIX' do
      let(:facts) { common_facts.merge({ operatingsystem: 'not-AIX' })}
      it { expect { catalogue }.to raise_error(/not supported/)}
    end
  end
end
