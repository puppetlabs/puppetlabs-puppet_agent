require 'spec_helper'

describe 'puppet_agent' do
  let(:common_facts) {
    {
      is_pe:           true,
      osfamily:        'AIX',
      operatingsystem: 'AIX',
      servername:      'master.example.vm',
      clientcert:      'foo.example.vm',
    }
  }

  shared_examples 'aix' do |aixver, pkg_aixver, powerver|
    let(:rpmname) {"puppet-agent-#{params[:package_version]}-1.aix#{pkg_aixver}.ppc.rpm"}
    let(:tag) { "aix-#{pkg_aixver}-power" }
    let(:source) { "puppet:///pe_packages/4.0.0/#{tag}/#{rpmname}" }
    let(:facts) {
      common_facts.merge({
        architecture: "PowerPC_POWER#{powerver}",
        platform_tag: "aix-#{aixver}-power",
      })
    }

    before(:each) do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) { |_args| '4.0.0' }
      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) { |_args| 'x.y.z' }
    end

    if Puppet.version < "4.0.0"
      it { is_expected.to contain_file('/etc/puppetlabs/puppet') }
      it { is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf') }

      it do
        is_expected.to contain_exec('replace puppet.conf removed by package removal').with_command('cp /etc/puppetlabs/puppet/puppet.conf.rpmsave /etc/puppetlabs/puppet/puppet.conf')
        is_expected.to contain_exec('replace puppet.conf removed by package removal').with_creates('/etc/puppetlabs/puppet/puppet.conf')
      end
    end

    it { is_expected.to contain_file('/opt/puppetlabs') }
    it { is_expected.to contain_file('/opt/puppetlabs/packages') }
    it { is_expected.to contain_file("/opt/puppetlabs/packages/#{rpmname}").with({ 'source' => source })
    }

    it { is_expected.to contain_class("puppet_agent::osfamily::aix") }

    it { is_expected.to contain_class('Puppet_agent::Install').with({ 'package_file_name' => rpmname, }) }

    it {
      is_expected.to contain_package('puppet-agent').with({
        'source'    => "/opt/puppetlabs/packages/#{rpmname}",
        'ensure'    => Puppet.version < '4.0.0' ? 'present' : params[:package_version],
        'provider'  => 'rpm',
      })
    }

    if Puppet.version < "4.0.0"
      [
          'pe-augeas',
          'pe-mcollective-common',
          'pe-rubygem-deep-merge',
          'pe-mcollective',
          'pe-puppet-enterprise-release',
          'pe-libldap',
          'pe-libyaml',
          'pe-ruby-stomp',
          'pe-ruby-augeas',
          'pe-ruby-shadow',
          'pe-hiera',
          'pe-facter',
          'pe-puppet',
          'pe-openssl',
          'pe-ruby',
          'pe-ruby-rgen',
          'pe-virt-what',
          'pe-ruby-ldap',
      ].each do |package|
        it do
          is_expected.to contain_package(package).with({
           'ensure' => 'absent',
           'uninstall_options' => '--nodeps',
           'provider' => 'rpm',
          })
        end
      end
    end
  end

  context 'with a PC1 collection' do
    let(:params) {
      {
        package_version: '1.2.3',
        collection: 'PC1',
      }
    }

    [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '6.1', '7'], ['5.3', '5.3', '7']].each do |aixver, pkg_aixver, powerver|
      context "aix #{aixver}" do
        include_examples 'aix', aixver, pkg_aixver, powerver
      end
    end
  end

  context 'with a puppet5 collection' do
    let(:params) {
      {
        package_version: '5.4.3',
        collection: 'puppet5',
      }
    }

    [['7.2', '7.1', '8'], ['7.1', '7.1', '8'], ['7.1', '7.1', '7'], ['6.1', '6.1', '7'], ['5.3', '5.3', '7']].each do |aixver, pkg_aixver, powerver|
      context "aix #{aixver}" do
        include_examples 'aix', aixver, pkg_aixver, powerver
      end
    end
  end

  context 'with a puppet6 collection' do
    let(:params) {
      {
        package_version: '6.0.0',
        collection: 'puppet6',
      }
    }

    [['7.2', '6.1', '8'], ['7.1', '6.1', '8'], ['7.1', '6.1', '7'], ['6.1', '6.1', '7']].each do |aixver, pkg_aixver, powerver|
      context "aix #{aixver}" do
        include_examples 'aix', aixver, pkg_aixver, powerver
      end
    end
  end
end
