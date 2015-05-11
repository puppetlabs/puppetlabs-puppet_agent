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
