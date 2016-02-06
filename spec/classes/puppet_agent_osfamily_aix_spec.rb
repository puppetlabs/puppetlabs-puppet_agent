require 'spec_helper'


describe 'puppet_agent', :unless => Puppet.version < "3.8.0" || Puppet.version >= "4.0.0" do
  before(:each) do
    Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
      "4.0.0"
    end

    Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
      '1.2.5'
    end
  end

  facts = {
    :is_pe           => true,
    :osfamily        => 'AIX',
    :operatingsystem => 'AIX',
    :servername      => 'master.example.vm',
    :clientcert      => 'foo.example.vm',
  }

  ['7', '6', '5'].each do |aixver|
    context "aix #{aixver}" do

      let(:facts) do
        facts.merge({
          :architecture    => "PowerPC_POWER#{aixver}",
          :platform_tag    => "aix-#{aixver}.1-power"
        })
      end

      rpmname = "puppet-agent-1.2.5-1.aix#{aixver}.1.ppc.rpm"

      it { is_expected.to contain_file('/etc/puppetlabs/puppet') }

      it { is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf') }

      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_file('/opt/puppetlabs/packages') }
      it { is_expected.to contain_file("/opt/puppetlabs/packages/#{rpmname}")}

      it { is_expected.to contain_class('Puppet_agent::Install').with({
           'package_file_name'     => rpmname,
         })
      }

      it {
        is_expected.to contain_package('puppet-agent').with({
            'source'    => "/opt/puppetlabs/packages/#{rpmname}",
            'ensure'    => 'present',
            'provider'  => 'rpm'
          })
      }

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
          is_expected.to contain_package(package).with_ensure('absent')
          is_expected.to contain_package(package).with_uninstall_options('--nodeps')
          is_expected.to contain_package(package).with_provider('rpm')
        end
      end
    end
  end

  ['4', '8'].each do |aixver|
    context "aix #{aixver}" do
      let(:facts) do
        facts.merge({
          :architecture    => "PowerPC_POWER#{aixver}",
          :platform_tag    => "aix-#{aixver}.1-power"
        })
      end

      rpmname = "puppet-agent-1.2.5-1.aix#{aixver}.1.ppc.rpm"

      it {
        is_expected.to_not contain_file("/opt/puppetlabs/packages/#{rpmname}") }
    end
  end
end

