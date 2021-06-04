require 'spec_helper'

describe Puppet::Type.type(:puppet_agent_end_run).provider(:puppet_agent_end_run) do
  let(:catalog) { Puppet::Resource::Catalog.new }

  before do
    allow(Facter).to receive(:value)
  end

  context 'when package_version is latest' do
    let(:resource) do
      Puppet::Type.type(:puppet_agent_end_run).new(:name => 'latest', :provider => :puppet_agent_end_run)
    end

    let(:agent_latest_package) do
      Puppet::Type.type(:package).new(:name => 'puppet-agent', :ensure => 'latest', :provider => :yum)
    end

    before do
      catalog.add_resource(agent_latest_package)
      resource.catalog = catalog
    end

    context 'with dev versions' do
      it 'does not stop the run if package is already latest' do
        catalog.resource('package', 'puppet-agent').parameters[:ensure].latest = '0:7.8.0.64.g6670bf40b-1.el8'
        allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.8.0.64')
        expect(Puppet::Application).not_to receive(:stop!)

        resource.provider.stop
      end

      it 'stops the run if the current and desired versions differ' do
        catalog.resource('package', 'puppet-agent').parameters[:ensure].latest = '0:7.8.0.64.g6670bf40b-1.el8'
        allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.8.0.32')
        expect(Puppet::Application).to receive(:stop!)

        resource.provider.stop
      end
    end

    context 'with released versions' do
      it 'does not stop the run if package is already latest' do
        catalog.resource('package', 'puppet-agent').parameters[:ensure].latest = '7.8.0-1.el8'
        allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.8.0')
        expect(Puppet::Application).not_to receive(:stop!)

        resource.provider.stop
      end


      it 'stops the run if the current and desired versions differ' do
        catalog.resource('package', 'puppet-agent').parameters[:ensure].latest = '7.9.0-1.el8'
        allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.8.0')
        expect(Puppet::Application).to receive(:stop!)

        resource.provider.stop
      end
    end
  end

  context 'when package_version is present' do
    let(:resource) do
      Puppet::Type.type(:puppet_agent_end_run).new(:name => 'present', :provider => :puppet_agent_end_run)
    end

    it 'never stops the run' do
      expect(Puppet::Application).not_to receive(:stop!)
      resource.provider.stop
    end
  end

  context 'when package_version is a released version' do
    let(:resource) do
      Puppet::Type.type(:puppet_agent_end_run).new(:name => '7.8.0', :provider => :puppet_agent_end_run)
    end

    it 'does not stop the run if current and desired versions match' do
      allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.8.0')
      expect(Puppet::Application).not_to receive(:stop!)

      resource.provider.stop
    end

    it 'stops the run if current and desired versions do not match' do
      allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.7.0')
      expect(Puppet::Application).to receive(:stop!)

      resource.provider.stop
    end
  end

  context 'when package_version is a nightly version' do
    let(:resource) do
      Puppet::Type.type(:puppet_agent_end_run).new(:name => '7.8.0.32', :provider => :puppet_agent_end_run)
    end

    it 'does not stop the run if current and desired versions match' do
      allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.8.0.32')
      expect(Puppet::Application).not_to receive(:stop!)

      resource.provider.stop
    end

    it 'stops the run if current and desired versions do not match' do
      allow(Facter).to receive(:value).with('aio_agent_version').and_return('7.8.0')
      expect(Puppet::Application).to receive(:stop!)

      resource.provider.stop
    end
  end
end
