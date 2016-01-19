require 'spec_helper'

describe 'puppet_agent', :if => Puppet.version >= '3.8.0' do
  context 'version is undefined' do
    let(:facts) { {
      :architecture => 'x86',
      :osfamily => 'RedHat',
    } }
    it { is_expected.to contain_package('puppet-agent').with_ensure('present') }
  end

  ['1.0.0', '1.0.0-1', '1.0.0.1'].each do |version|
    context "version is #{version}" do
      let(:facts) { {
        :architecture => 'x86',
        :osfamily => 'RedHat',
      } }
      let(:params) { {:package_version => version} }
      it { is_expected.to contain_package('puppet-agent').with_ensure(version) }
    end
  end

  context 'version is foo' do
    let(:facts) { {
      :architecture => 'x86',
      :osfamily => 'RedHat',
    } }
    let(:params) { {:package_version => 'foo'} }
    it { expect {is_expected.to contain_package('puppet_agent') }.to raise_error(Puppet::Error, /invalid version foo requested/) }
  end
end
