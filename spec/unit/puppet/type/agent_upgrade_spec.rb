require 'spec_helper'

RSpec.describe Puppet::Type.type(:agent_upgrade) do

  let(:params) { {:name => 'Windows update'} }

  before :each do
    Facter.stubs(:value).with(:osfamily).returns('windows')
  end

  shared_examples 'valid parameter' do |param, value|
    it {
      resource = described_class.new({:name => 'Windows Update'}.merge({param => value}))
      expect(resource[param]).to eq value
    }
  end

  shared_examples 'fail validation' do |params, error_regexp|
    it {
      expect {
        described_class.new({:name => 'Windows Update'}.merge(params))
      }.to raise_error(Puppet::ResourceError, error_regexp)
    }
  end

  context 'arch =>' do
    it_behaves_like 'valid parameter', :arch, 'x64'
    it_behaves_like 'valid parameter', :arch, 'x86'
    it_behaves_like 'fail validation', {:arch => 'i386'},
                    /Invalid value \"i386\"\. Valid values match \/\^\(x86\|x64\)\$/
  end

  context 'source =>' do
    it_behaves_like 'valid parameter', :source, 'https://dl.pl.com:8540'
    it_behaves_like 'valid parameter', :source, 'http://dl.pl.com:8540'
    it_behaves_like 'valid parameter', :source, '\\\\mycomputer\\sharedFolder\\puppet-agent.msi'
    it_behaves_like 'valid parameter', :source, '\\\\mycomputer\\sharedFolder\\puppet-agent.msi'
    it_behaves_like 'valid parameter', :source, 'C:\\tmp\\puppet-agent.msi'
    it_behaves_like 'valid parameter', :source, 'z:\\tmp\\puppet-agent.msi'


    it_behaves_like 'fail validation', {:source => 'ftp://dl.pl.com'},
                    /Please provide a valid http\(s\), puppet or unc path/
  end

  context 'version =>' do
    it_behaves_like 'valid parameter', :version, '1.0.0'
    it_behaves_like 'valid parameter', :version, '2.0.0'
    it_behaves_like 'valid parameter', :version, 'latest'
    it_behaves_like 'fail validation', {:version => 'crazy'},
                    /Valid values are 'latest' or full version numbers, you provided 'crazy'/
  end

end
