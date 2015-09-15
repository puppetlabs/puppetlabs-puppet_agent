require 'spec_helper'

describe 'puppet_agent', :unless => Puppet.version < "3.8.0" || Puppet.version >= "4.0.0" do
  facts = {
    :lsbdistid => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :operatingsystem => 'Debian',
    :architecture => 'x64',
      :servername   => 'master.example.vm',
      :clientcert   => 'foo.example.vm',
  }

  let(:facts) { facts }

  it { is_expected.to contain_class('apt') }

  context 'when PE' do
    before(:each) do
      # Need to mock the PE functions

      Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
        '4.0.0'
      end

      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
        '1.2.5'
      end
    end

    let(:facts) {
      facts.merge({
        :is_pe        => true,
        :platform_tag => 'debian-7-x86_64',
      })
    }

    it { is_expected.to contain_apt__setting('conf-pe-repo').with({
      'priority' => 90,
      'content'  => '',
      'ensure'   => 'absent',
    }) }

    it { is_expected.to contain_apt__setting('list-puppet-enterprise-installer').with({
      'content'  => '',
      'ensure'   => 'absent',
    }) }

    apt_settings = [
      "Acquire::https::master.example.vm::CaInfo \"/etc/puppetlabs/puppet/ssl/certs/ca.pem\";",
      "Acquire::https::master.example.vm::SslCert \"/etc/puppetlabs/puppet/ssl/certs/foo.example.vm.pem\";",
      "Acquire::https::master.example.vm::SslKey \"/etc/puppetlabs/puppet/ssl/private_keys/foo.example.vm.pem\";",
      "Acquire::http:::proxy::master.example.vm DIRECT;",
    ]
    it { is_expected.to contain_apt__setting('conf-pc1_repo').with({
      'priority' => 90,
      'content'  => apt_settings.join(''),
    }) }

    it { is_expected.to contain_apt__source('pc1_repo').with({
      'location' => 'https://master.example.vm:8140/packages/4.0.0/debian-7-x86_64',
      'repos'    => 'PC1',
      'key'      => {
        'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
        'server' => 'pgp.mit.edu',
      },
    }) }

  end

  context 'when FOSS' do
    it { is_expected.not_to contain_apt__setting('conf-pe-repo') }
    it { is_expected.not_to contain_apt__setting('list-puppet-enterprise-installer') }

    it { is_expected.to contain_apt__source('pc1_repo').with({
      'location' => 'http://apt.puppetlabs.com',
      'repos'    => 'PC1',
      'key'      => {
        'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
        'server' => 'pgp.mit.edu',
      },
    }) }
  end
end
