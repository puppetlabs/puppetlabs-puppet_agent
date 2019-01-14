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

describe "puppet_stringify_facts fact" do
  subject { Facter.fact("puppet_stringify_facts".to_sym).value }  
  after(:each) { Facter.clear }

  describe 'should always be false' do
    it { is_expected.to eq(false) }
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
