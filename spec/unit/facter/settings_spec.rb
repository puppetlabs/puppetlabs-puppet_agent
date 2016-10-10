require 'spec_helper'

describe 'puppet_ssldir fact' do
  subject { Facter.fact(:puppet_ssldir).value }
  after(:each) { Facter.clear }

  describe 'should point to an existing directory' do
    it { is_expected.to eq('/dev/null/ssl') }
  end
end

describe 'puppet_config fact' do
  subject { Facter.fact(:puppet_config).value }
  after(:each) { Facter.clear }

  describe 'should point to an existing file' do
    it { is_expected.to eq('/dev/null/puppet.conf') }
  end
end

describe "puppet_stringify_facts fact for Puppet 4.x+", :unless => /3\./ =~ Puppet.version do
  subject { Facter.fact("puppet_stringify_facts".to_sym).value }  
  after(:each) { Facter.clear }

  describe 'should always be false' do
    it { is_expected.to eq(false) }
  end
end

describe "puppet_stringify_facts fact for Puppet 3.x", :if => /3\./ =~ Puppet.version do
  subject { Facter.fact("puppet_stringify_facts".to_sym).value }  
  after(:each) { Facter.clear }

  describe 'when not set in Puppet' do
    before(:each) {
      mocked_settings = Puppet::Settings.new
      Puppet.stubs(:settings).returns(mocked_settings)
    }
    it { is_expected.to eq(false) }
  end

  describe 'when set false in Puppet' do
    before(:each) {
      mocked_settings = Puppet::Settings.new
      mocked_settings.define_settings :main, :stringify_facts => { :default => false, :type => :boolean, :desc => 'mocked stringify_facts setting' }
      Puppet.stubs(:settings).returns(mocked_settings)
    }

    it { is_expected.to eq(false) }
  end

  describe 'when set true in Puppet' do
    before(:each) {
      mocked_settings = Puppet::Settings.new
      mocked_settings.define_settings :main, :stringify_facts => { :default => true, :type => :boolean, :desc => 'mocked stringify_facts setting' }
      Puppet.stubs(:settings).returns(mocked_settings)
    }

    it { is_expected.to eq(true) }
  end
end

describe "puppet_sslpaths fact" do
  subject { Facter.fact("puppet_sslpaths".to_sym).value }
  after(:each) { Facter.clear }

  { 'privatedir'    => 'ssl/private',
    'privatekeydir' => 'ssl/private_keys',
    'publickeydir'  => 'ssl/public_keys',
    'certdir'       => 'ssl/certs',
    'requestdir'    => 'ssl/certificate_requests',
    'hostcrl'       => 'ssl/crl.pem',
  }.each_pair do |name, path|
    describe name do
      it { is_expected.to include(name => { 'path' => "/dev/null/#{path}", 'path_exists' => false})}
    end
  end
end
