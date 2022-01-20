require 'spec_helper'

describe 'puppet_agent' do
  let(:common_facts) do
    {
      architecture:               'PowerPC_POWER7',
      clientcert:                 'foo.example.vm',
      is_pe:                      true,
      operatingsystem:            'AIX',
      osfamily:                   'AIX',
      platform_tag:               'aix-7.2-power',
      servername:                 'master.example.vm',
    }
  end

  shared_examples 'aix' do |aixver, pkg_aixver, powerver|
    let(:rpmname) { "puppet-agent-#{params[:package_version]}-1.aix#{pkg_aixver}.ppc.rpm" }
    let(:tag) { "aix-#{pkg_aixver}-power" }
    let(:source) { "puppet:///pe_packages/2000.0.0/#{tag}/#{rpmname}" }
    let(:facts) do
      common_facts.merge({
                           architecture: "PowerPC_POWER#{powerver}",
                           platform_tag: "aix-#{aixver}-power",
                         })
    end

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2000.0.0' }
      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) { |_args| '1.10.100' }
    end

    it { is_expected.to contain_file('/opt/puppetlabs') }
    it { is_expected.to contain_file('/opt/puppetlabs/packages') }
    it {
      is_expected.to contain_file("/opt/puppetlabs/packages/#{rpmname}").with({ 'source' => source })
    }

    it { is_expected.to contain_class('puppet_agent::osfamily::aix') }

    it { is_expected.to contain_class('Puppet_agent::Install') }

    it {
      is_expected.to contain_package('puppet-agent')
        .with({
                'source'    => "/opt/puppetlabs/packages/#{rpmname}",
                'ensure'    => params[:package_version],
                'provider'  => 'rpm',
              })
    }
  end

  context 'with a user specified source' do
    let(:facts) do
      common_facts.merge({
                           architecture: 'PowerPC_POWER8',
                           platform_tag: 'aix-6.1-power',
                         })
    end
    let(:params) do
      {
        package_version: '5.10.100.1',
        collection: 'puppet5',
        source: 'https://fake-pe-master.com',
      }
    end

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2000.0.0' }
      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) { |_args| '1.10.100' }
    end

    it {
      is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-5.10.100.1-1.aix7.1.ppc.rpm').with_source('https://fake-pe-master.com/packages/2000.0.0/aix-7.1-power/puppet-agent-5.10.100.1-1.aix7.1.ppc.rpm')
    }
  end

  context 'with a PC1 collection' do
    let(:params) do
      {
        package_version: '1.10.100',
        collection: 'PC1',
      }
    end

    [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '6.1', '7']].each do |aixver, pkg_aixver, powerver|
      context "aix #{aixver}" do
        include_examples 'aix', aixver, pkg_aixver, powerver
      end
    end
  end

  context 'with a puppet5 collection' do
    context 'with versions up to 5.5.22' do
      let(:params) do
        {
          package_version: '5.4.3',
          collection: 'puppet5',
        }
      end

      [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '6.1', '7']].each do |aixver, pkg_aixver, powerver|
        context "aix #{aixver}" do
          include_examples 'aix', aixver, pkg_aixver, powerver
        end
      end
    end

    context 'with versions higher than 5.5.22' do
      let(:params) do
        {
          package_version: '5.5.23',
          collection: 'puppet5',
        }
      end

      [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '7.1', '7']].each do |aixver, pkg_aixver, powerver|
        context "aix #{aixver}" do
          include_examples 'aix', aixver, pkg_aixver, powerver
        end
      end
    end
  end

  context 'with a puppet6 collection' do
    context 'with versions up to 6.19.1' do
      let(:params) do
        {
          package_version: '6.0.0',
          collection: 'puppet6',
        }
      end

      [['7.2', '6.1', '8'], ['7.1', '6.1', '8'], ['7.1', '6.1', '7'], ['6.1', '6.1', '7']].each do |aixver, pkg_aixver, powerver|
        context "aix #{aixver}" do
          include_examples 'aix', aixver, pkg_aixver, powerver
        end
      end
    end

    context 'with versions higher than 6.19.1' do
      let(:params) do
        {
          package_version: '6.20.0',
          collection: 'puppet6',
        }
      end

      [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '7.1', '7']].each do |aixver, pkg_aixver, powerver|
        context "aix #{aixver}" do
          include_examples 'aix', aixver, pkg_aixver, powerver
        end
      end
    end
  end

  context 'with a puppet7 collection' do
    context 'with versions higher than 7.0.0' do
      let(:params) do
        {
          package_version: '7.0.1',
          collection: 'puppet7',
        }
      end

      [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '7.1', '7']].each do |aixver, pkg_aixver, powerver|
        context "aix #{aixver}" do
          include_examples 'aix', aixver, pkg_aixver, powerver
        end
      end
    end
  end

  context 'with package_version auto' do
    let(:params) do
      {
        package_version: 'auto',
      }
    end
    let(:facts) do
      common_facts.merge({
                           serverversion: '5.10.200'
                         })
    end
    let(:rpmname) { 'puppet-agent-5.10.200-1.aix7.1.ppc.rpm' }

    it {
      is_expected.to contain_package('puppet-agent')
        .with({
                'source'    => "/opt/puppetlabs/packages/#{rpmname}",
                'ensure'    => '5.10.200',
                'provider'  => 'rpm',
              })
    }
  end

  context 'unsupported environments' do
    let(:params) do
      {
        package_version: '6.0.0',
        collection: 'puppet6'
      }
    end

    context 'not AIX' do
      let(:facts) { common_facts.merge({ operatingsystem: 'not-AIX' }) }

      it { expect { catalogue }.to raise_error(%r{not supported}) }
    end
  end
end
