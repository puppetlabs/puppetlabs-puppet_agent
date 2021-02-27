require 'spec_helper'

describe 'settings' do
  let(:location) { File.expand_path('/dev/null') }

  describe 'puppet_digest_algorithm fact' do
    subject { Facter.fact(:puppet_digest_algorithm).value }
    after(:each) { Facter.clear }

    describe 'should be one of md5/sha256' do
      it { is_expected.to match(%r{md5|sha256}) }
    end
  end

  describe 'puppet_ssldir fact' do
    subject { Facter.fact(:puppet_ssldir).value }
    after(:each) { Facter.clear }

    describe 'should point to an existing directory' do
      it { is_expected.to eq("#{location}/ssl") }
    end
  end

  describe 'puppet_config fact' do
    subject { Facter.fact(:puppet_config).value }
    after(:each) { Facter.clear }

    describe 'should point to an existing file' do
      it { is_expected.to eq("#{location}/puppet.conf") }
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
        it { is_expected.to include(name => { 'path' => "#{location}/#{path}", 'path_exists' => false})}
      end
    end
  end
end
