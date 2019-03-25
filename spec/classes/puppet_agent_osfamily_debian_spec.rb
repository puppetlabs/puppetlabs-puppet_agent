require 'spec_helper'

describe 'puppet_agent' do
  facts = {
    :lsbdistid            => 'Debian',
    :osfamily             => 'Debian',
    :lsbdistcodename      => 'stretch',
    :os                   => {
                               'name' => 'Debian',
                               'release' => {
                                 'full' => '9.0',
                                 'major' => '9',
                               },
                             },
    :operatingsystem      => 'Debian',
    :architecture         => 'x64',
    :puppet_master_server => 'master.example.vm',
    :clientcert           => 'foo.example.vm',
  }

  # All FOSS and all Puppet 4+ upgrades require the package_version
  package_version = '1.10.100'
  let(:params) {
    {
      :package_version => package_version
    }
  }
  let(:facts) { facts }

  it { is_expected.to contain_class('apt') }
  it { is_expected.to contain_exec('pc_repo_force') }

  context 'when PE' do
    before(:each) do
      # Need to mock the PE functions

      Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
        '2000.0.0'
      end

      Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
        package_version
      end
    end

    let(:facts) {
      facts.merge({
        :is_pe        => true,
        :platform_tag => 'debian-7-x86_64',
      })
    }

    context "when managing PE debian apt repo" do
      let(:params) {
        {
          :manage_repo => true,
          :package_version => package_version
        }
      }

      it { is_expected.to contain_class('apt') }
      it { is_expected.to contain_exec('pc_repo_force') }
      it { is_expected.to contain_apt__setting('conf-pe-repo').with({
        'priority' => 90,
        'content'  => '',
        'ensure'   => 'absent',
      }) }

      it { is_expected.to contain_apt__setting('list-puppet-enterprise-installer').with({
        'content'  => '',
        'ensure'   => 'absent',
      }) }
    end

    context "when not managing PE debian apt repo" do
      let(:params) {
        {
          :manage_repo => false,
          :package_version => package_version
        }
      }

      it { is_expected.not_to contain_class('apt') }
      it { is_expected.not_to contain_exec('pc_repo_force') }
      it { is_expected.not_to contain_apt__setting('conf-pe-repo') }

      it { is_expected.not_to contain_apt__setting('list-puppet-enterprise-installer') }
    end

    context "xenial" do
      let(:facts) {
        facts.merge({
          :is_pe        => true,
          :platform_tag => 'ubuntu-1604-x86_64',
          :operatingsystem => 'Ubuntu',
          :lsbdistcodename => 'xenial',
          :os => {
            'name' => 'Ubuntu',
            'release' => {
              'full' => '16.04',
            },
          },
        })
      }

      context "when managing debian xenial apt repo" do
        let(:params) {
          {
            :manage_repo => true,
            :package_version => package_version
          }
        }

        it { is_expected.to contain_class('apt') }
        it { is_expected.to contain_exec('pc_repo_force') }

        apt_settings = [
          "Acquire::https::master.example.vm::CaInfo \"/etc/puppetlabs/puppet/ssl/certs/ca.pem\";",
          "Acquire::http::proxy::master.example.vm DIRECT;",
        ]
        it { is_expected.to contain_apt__setting('conf-pc_repo').with({
          'priority' => 90,
          'content'  => apt_settings.join(''),
        }) }
      end

      context "when not managing debian xenial apt repo" do
        let(:params) {
          {
            :manage_repo => false,
            :package_version => package_version
          }
        }

        it { is_expected.not_to contain_class('apt') }
        it { is_expected.not_to contain_exec('pc_repo_force') }

        it { is_expected.not_to contain_apt__setting('conf-pc_repo') }
      end

    end

    context "when managing PE apt repo settings" do
      let(:params) {
        {
          :manage_repo => true,
          :package_version => package_version
        }
      }

      apt_settings = [
        "Acquire::https::master.example.vm::CaInfo \"/etc/puppetlabs/puppet/ssl/certs/ca.pem\";",
        "Acquire::http::proxy::master.example.vm DIRECT;",
      ]
      it { is_expected.to contain_apt__setting('conf-pc_repo').with({
        'priority' => 90,
        'content'  => apt_settings.join(''),
      }) }

      it { is_expected.to contain_file('/etc/pki/deb-gpg/GPG-KEY-puppetlabs').with({
        'ensure' => 'present',
        'owner'  => '0',
        'group'  => '0',
        'mode'   => '0644',
        'source' => 'puppet:///modules/puppet_agent/GPG-KEY-puppetlabs',
      }) }

      it { is_expected.to contain_file('/etc/pki/deb-gpg/GPG-KEY-puppet').with({
        'ensure' => 'present',
        'owner'  => '0',
        'group'  => '0',
        'mode'   => '0644',
        'source' => 'puppet:///modules/puppet_agent/GPG-KEY-puppet',
      }) }

      it { is_expected.to contain_apt__key('legacy key').with({
        'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
        'source' => '/etc/pki/deb-gpg/GPG-KEY-puppetlabs',
      }) }

      it { is_expected.to contain_apt__source('pc_repo').with({
        'location' => 'https://master.example.vm:8140/packages/2000.0.0/debian-7-x86_64',
        'repos'    => 'PC1',
        'key'      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'source' => '/etc/pki/deb-gpg/GPG-KEY-puppet',
        },
      }) }
    end

    context "when managing PE apt repo settings and using a custom source" do
      let(:params) {
        {
          :manage_repo => true,
          :package_version => package_version,
          :source => 'https://fake-apt-mirror.com'
        }
      }

      it { is_expected.to contain_apt__source('pc_repo').with({
        'location' => 'https://fake-apt-mirror.com/packages/2000.0.0/debian-7-x86_64',
        'repos'    => 'PC1',
        'key'      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'source' => '/etc/pki/deb-gpg/GPG-KEY-puppet',
        },
      }) }
    end

    context "when not managing PE apt repo settings" do
      let(:params) {
        {
          :manage_repo => false,
          :package_version => package_version
        }
      }

      it { is_expected.not_to contain_apt__setting('conf-pc_repo') }
      it { is_expected.not_to contain_apt__key('legacy key') }
      it { is_expected.not_to contain_apt__source('pc_repo') }
    end

    it { is_expected.to contain_class("puppet_agent::osfamily::debian") }

  end

  context 'when FOSS' do

    it { is_expected.not_to contain_apt__setting('conf-pe-repo') }
    it { is_expected.not_to contain_apt__setting('list-puppet-enterprise-installer') }

    context "when managing FOSS apt repo" do
      let(:params) {
        {
          :manage_repo => true,
          :package_version => package_version,
          :collection => 'puppet5',
        }
      }

      it { is_expected.to contain_apt__key('legacy key').with({
        'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
        'source' => '/etc/pki/deb-gpg/GPG-KEY-puppetlabs',
      }) }

      it { is_expected.to contain_apt__source('pc_repo').with({
        'location' => 'https://apt.puppet.com',
        'repos'    => 'puppet5',
        'key'      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'source' => '/etc/pki/deb-gpg/GPG-KEY-puppet',
        },
      }) }
    end

    context "when managing FOSS apt repo and using a custom source" do
      let(:params) {
        {
          :manage_repo => true,
          :package_version => package_version,
          :collection => 'puppet5',
          :apt_source => 'https://fake-apt-mirror.com/'
        }
      }

      it { is_expected.to contain_apt__source('pc_repo').with({
        'location' => 'https://fake-apt-mirror.com/',
        'repos'    => 'puppet5',
        'key'      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'source' => '/etc/pki/deb-gpg/GPG-KEY-puppet',
        },
      }) }
    end

    context "when not managing FOSS apt repo" do
      let(:params) {
        {
          :manage_repo => false,
          :package_version => package_version
        }
      }

      it { is_expected.not_to contain_apt__key('legacy key') }
      it { is_expected.not_to contain_apt__source('pc_repo') }
    end

    it { is_expected.to contain_class("puppet_agent::osfamily::debian") }
  end
end
