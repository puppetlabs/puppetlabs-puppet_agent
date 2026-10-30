require 'spec_helper'

describe 'puppet_agent' do
  let(:common_facts) do
    {
      clientcert: 'foo.example.vm',
      is_pe: true,
      os: {
        architecture: 'PowerPC_POWER7',
        family: 'AIX',
        name: 'AIX',
      },
      platform_tag: 'aix-7.2-power',
      servername: 'master.example.vm',
    }
  end

  before(:each) do
    allow(Puppet::FileSystem).to receive(:exist?).and_call_original
    allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).and_call_original
    allow(Puppet::FileSystem).to receive(:exist?).with('/opt/puppetlabs/puppet/VERSION').and_return true
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

  context 'with a user specified source for puppet 7' do
    let(:facts) do
      common_facts.merge({
                           architecture: 'PowerPC_POWER8',
                           platform_tag: 'aix-7.1-power',
                         })
    end
    let(:params) do
      {
        package_version: '7.10.100.1',
        collection: 'puppet7',
        source: 'https://fake-pe-master.com',
      }
    end

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2021.7.7' }
    end

    it {
      is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-7.10.100.1-1.aix7.1.ppc.rpm').with_source('https://fake-pe-master.com/packages/2021.7.7/aix-power/puppet-agent-7.10.100.1-1.aix7.1.ppc.rpm')
    }
  end

  context 'with a user specified source for puppet 8' do
    let(:facts) do
      common_facts.merge({
                           architecture: 'PowerPC_POWER8',
                           platform_tag: 'aix-7.2-power',
                         })
    end
    let(:params) do
      {
        package_version: '8.10.100.1',
        collection: 'puppet8',
        source: 'https://fake-pe-master.com',
      }
    end

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2023.6.0' }
    end

    it {
      is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-8.10.100.1-1.aix7.2.ppc.rpm').with_source('https://fake-pe-master.com/packages/2023.6.0/aix-power/puppet-agent-8.10.100.1-1.aix7.2.ppc.rpm')
    }
  end

  context 'with a user specified source for puppet 9' do
    let(:facts) do
      common_facts.merge({
                           architecture: 'PowerPC_POWER8',
                           platform_tag: 'aix-7.3-power',
                         })
    end
    let(:params) do
      {
        package_version: '9.1.1',
        collection: 'puppet9',
        source: 'https://fake-pe-master.com',
      }
    end

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2026.0.0' }
    end

    it {
      is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-9.1.1-1.aix7.2.ppc.rpm').with_source('https://fake-pe-master.com/packages/2026.0.0/aix-power/puppet-agent-9.1.1-1.aix7.2.ppc.rpm')
    }
  end

  context 'with an alternate_pe_source for puppet 9' do
    let(:facts) do
      common_facts.merge({
                           architecture: 'PowerPC_POWER8',
                           platform_tag: 'aix-7.3-power',
                         })
    end
    let(:params) do
      {
        package_version: '9.1.1',
        collection: 'puppet9',
        alternate_pe_source: 'https://fake-alternate-source.com',
      }
    end

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '2026.0.0' }
    end

    it {
      is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-9.1.1-1.aix7.2.ppc.rpm').with_source('https://fake-alternate-source.com/packages/2026.0.0/aix-power/puppet-agent-9.1.1-1.aix7.2.ppc.rpm')
    }
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

  [['puppet8', '8.0.0'], ['puppet9', '9.1.1'], ['puppet10', '10.0.0']].each do |collection, package_version|
    context "with a #{collection} collection" do
      let(:params) do
        {
          package_version: package_version,
          collection: collection,
        }
      end

      [['7.2', '7.2', '8'], ['7.3', '7.2', '9']].each do |aixver, pkg_aixver, powerver|
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
                           serverversion: '7.10.200'
                         })
    end
    let(:rpmname) { 'puppet-agent-7.10.200-1.aix7.1.ppc.rpm' }

    before(:each) do
      allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).with('/opt/puppetlabs/puppet/VERSION').and_return "7.10.200\n"
    end

    it {
      is_expected.to contain_package('puppet-agent')
        .with({
                'source'    => "/opt/puppetlabs/packages/#{rpmname}",
                'ensure'    => '7.10.200',
                'provider'  => 'rpm',
              })
    }
  end

  context 'unsupported environments' do
    let(:params) do
      {
        package_version: '8.0.0',
        collection: 'puppet8'
      }
    end

    context 'not AIX' do
      let(:facts) do
        override_facts(common_facts, os: { name: 'not-AIX' })
      end

      it { expect { catalogue }.to raise_error(%r{not supported}) }
    end
  end
end
