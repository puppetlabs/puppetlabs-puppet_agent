require 'spec_helper'

describe 'puppet_agent', :if => Puppet.version >= '3.8.0' do
  context 'version is undefined' do
    let(:facts) { {
      :architecture => 'x86',
      :osfamily => 'RedHat',
    } }
    it { is_expected.to contain_package('puppet-agent').with_ensure('present') }
  end

  context 'version is 1.0.0' do
    let(:facts) { {
      :architecture => 'x86',
      :osfamily => 'RedHat',
    } }
    let(:params) { {:version => '1.0.0'} }
    it { is_expected.to contain_package('puppet-agent').with_ensure('1.0.0') }
  end

  context 'version is foo' do
    let(:facts) { {
      :architecture => 'x86',
      :osfamily => 'RedHat',
    } }
    let(:params) { {:version => 'foo'} }
    it { expect {is_expected.to contain_package('puppet_agent') }.to raise_error(Puppet::Error, /invalid version foo requested/) }
  end
end
