require 'spec_helper'


describe 'puppet_agent' do
  before(:each) do
    Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
      "4.0.0"
    end

    Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
      '1.2.5'
    end
  end

  package_version = '1.2.5'
  package_ensure = 'present'
  let(:params) do
    {
      :package_version => package_version
    }
  end

  facts = {
    :is_pe           => true,
    :osfamily        => 'AIX',
    :operatingsystem => 'AIX',
    :servername      => 'master.example.vm',
    :clientcert      => 'foo.example.vm',
  }

  [['7.1', '8'], ['7.1', '7'], ['6.1', '7'], ['5.3', '7']].each do |aixver, powerver|
    context "aix #{aixver}" do

      let(:facts) do
        facts.merge({
          :architecture    => "PowerPC_POWER#{powerver}",
          :platform_tag    => "aix-#{aixver}-power"
        })
      end

      rpmname = "puppet-agent-#{package_version}-1.aix#{aixver}.ppc.rpm"

      if Puppet.version < "4.0.0"
        it { is_expected.to contain_file('/etc/puppetlabs/puppet') }
        it { is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf') }
      end

      it do
        is_expected.to contain_exec('replace puppet.conf removed by package removal').with_command('cp /etc/puppetlabs/puppet/puppet.conf.rpmsave /etc/puppetlabs/puppet/puppet.conf')
        is_expected.to contain_exec('replace puppet.conf removed by package removal').with_creates('/etc/puppetlabs/puppet/puppet.conf')
      end

      it { is_expected.to contain_file('/opt/puppetlabs') }
      it { is_expected.to contain_file('/opt/puppetlabs/packages') }
      it { is_expected.to contain_file("/opt/puppetlabs/packages/#{rpmname}")}

      it { is_expected.to contain_class("puppet_agent::osfamily::aix") }

      it { is_expected.to contain_class('Puppet_agent::Install').with({
           'package_file_name'     => rpmname,
         })
      }

      it {
        is_expected.to contain_package('puppet-agent').with({
            'source'    => "/opt/puppetlabs/packages/#{rpmname}",
            'ensure'    => package_ensure,
            'provider'  => 'rpm'
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
            if Puppet.version < "4.0.0"
            else
              is_expected.to contain_transition("remove #{package}").with(
                :attributes => {
                  'ensure' => 'absent',
                  'uninstall_options' => '--nodeps',
                  'provider' => 'rpm',
                })
            end
          end
        end
      end
    end
  end
end
