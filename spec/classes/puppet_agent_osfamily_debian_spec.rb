require 'spec_helper'

describe 'puppet_agent' do
  facts = {
    clientcert: 'foo.example.vm',
    os: {
      architecture: 'x64',
      family: 'Debian',
      name: 'Debian',
      distro: {
        codename: 'buster',
        id: 'Debian',
      },
      release: {
        full: '10.0',
        major: '10',
      },
    },
    puppet_master_server: 'master.example.vm',
  }

  # All FOSS and all Puppet 4+ upgrades require the package_version
  package_version = '1.10.100'
  let(:params) do
    {
      package_version:
    }
  end
  let(:facts) { facts }

  it { is_expected.to contain_class('apt') }
  it { is_expected.to contain_exec('pc_repo_force') }

  context 'when PE' do
    before(:each) do
      # Need to mock the PE functions

      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
        '2000.0.0'
      end
    end

    let(:facts) do
      override_facts(facts, is_pe: true, platform_tag: 'debian-7-x86_64')
    end

    context 'when managing PE debian apt repo' do
      let(:params) do
        {
          manage_repo: true,
          package_version:
        }
      end

      it { is_expected.to contain_class('apt') }
      it { is_expected.to contain_exec('pc_repo_force') }
      it {
        is_expected.to contain_apt__setting('conf-pe-repo')
          .with({
                  'priority' => 90,
                  'ensure'   => 'absent',
                })
      }

      it {
        is_expected.to contain_apt__setting('list-puppet-enterprise-installer')
          .with({
                  'ensure' => 'absent',
                })
      }
    end

    context 'when not managing PE debian apt repo' do
      let(:params) do
        {
          manage_repo: false,
          package_version:
        }
      end

      it { is_expected.not_to contain_class('apt') }
      it { is_expected.not_to contain_exec('pc_repo_force') }
      it { is_expected.not_to contain_apt__setting('conf-pe-repo') }

      it { is_expected.not_to contain_apt__setting('list-puppet-enterprise-installer') }
    end

    context 'focal' do
      let(:facts) do
        override_facts(facts, is_pe: true, os: { distro: { codename: 'focal', }, name: 'Ubuntu', release: { full: '20.04', }, }, platform_tag: 'ubuntu-2004-x86_64')
      end

      context 'when managing debian focal apt repo' do
        let(:params) do
          {
            manage_repo: true,
            package_version:
          }
        end

        it { is_expected.to contain_class('apt') }
        it { is_expected.to contain_exec('pc_repo_force') }

        apt_settings = [
          'Acquire::https::master.example.vm::CaInfo "/etc/puppetlabs/puppet/ssl/certs/ca.pem";',
          'Acquire::http::proxy::master.example.vm DIRECT;',
        ]
        it {
          is_expected.to contain_apt__setting('conf-pc_repo')
            .with({
                    'priority' => 90,
                    'content'  => apt_settings.join(''),
                  })
        }
      end

      context 'when not managing debian focal apt repo' do
        let(:params) do
          {
            manage_repo: false,
            package_version:
          }
        end

        it { is_expected.not_to contain_class('apt') }
        it { is_expected.not_to contain_exec('pc_repo_force') }

        it { is_expected.not_to contain_apt__setting('conf-pc_repo') }
      end
    end

    context 'when managing PE apt repo settings' do
      let(:params) do
        {
          manage_repo: true,
          package_version:
        }
      end

      apt_settings = [
        'Acquire::https::master.example.vm::CaInfo "/etc/puppetlabs/puppet/ssl/certs/ca.pem";',
        'Acquire::http::proxy::master.example.vm DIRECT;',
      ]
      it {
        is_expected.to contain_apt__setting('conf-pc_repo')
          .with({
                  'priority' => 90,
                  'content'  => apt_settings.join(''),
                })
      }

      it {
        is_expected.to contain_apt__source('pc_repo')
          .with({
                  'location' => 'https://master.example.vm:8140/packages/2000.0.0/debian-7-x86_64',
                  'repos'    => 'PC1',
                  'key'      => {
                    'name'    => 'puppet-keyring.gpg',
                    'source'  => 'puppet:///modules/puppet_agent/puppet-keyring.gpg',
                  },
                })
      }
    end

    context 'when managing PE apt repo settings and using a custom source' do
      let(:params) do
        {
          manage_repo: true,
          package_version:,
          source: 'https://fake-apt-mirror.com'
        }
      end

      it {
        is_expected.to contain_apt__source('pc_repo')
          .with({
                  'location' => 'https://fake-apt-mirror.com/packages/2000.0.0/debian-7-x86_64',
                  'repos'    => 'PC1',
                  'key'      => {
                    'name'    => 'puppet-keyring.gpg',
                    'source'  => 'puppet:///modules/puppet_agent/puppet-keyring.gpg',
                  },
                })
      }
    end

    context 'when not managing PE apt repo settings' do
      let(:params) do
        {
          manage_repo: false,
          package_version:
        }
      end

      it { is_expected.not_to contain_apt__setting('conf-pc_repo') }
      it { is_expected.not_to contain_apt__source('pc_repo') }
    end

    it { is_expected.to contain_class('puppet_agent::osfamily::debian') }
  end

  context 'when FOSS' do
    it { is_expected.not_to contain_apt__setting('conf-pe-repo') }
    it { is_expected.not_to contain_apt__setting('list-puppet-enterprise-installer') }

    context 'when managing FOSS apt repo' do
      let(:params) do
        {
          manage_repo: true,
          package_version:,
          collection: 'puppet5',
        }
      end

      it {
        is_expected.to contain_apt__source('pc_repo')
          .with({
                  'location' => 'https://apt.puppet.com',
                  'repos'    => 'puppet5',
                  'key'      => {
                    'name'    => 'puppet-keyring.gpg',
                    'source'  => 'puppet:///modules/puppet_agent/puppet-keyring.gpg',
                  },
                })
      }
    end

    context 'when managing FOSS apt repo and using a custom source' do
      let(:params) do
        {
          manage_repo: true,
          package_version:,
          collection: 'puppet5',
          apt_source: 'https://fake-apt-mirror.com/'
        }
      end

      it {
        is_expected.to contain_apt__source('pc_repo')
          .with({
                  'location' => 'https://fake-apt-mirror.com/',
                  'repos'    => 'puppet5',
                  'key'      => {
                    'name'    => 'puppet-keyring.gpg',
                    'source'  => 'puppet:///modules/puppet_agent/puppet-keyring.gpg',
                  },
                })
      }
    end

    context 'when not managing FOSS apt repo' do
      let(:params) do
        {
          manage_repo: false,
          package_version:
        }
      end

      it { is_expected.not_to contain_apt__source('pc_repo') }
    end

    it { is_expected.to contain_class('puppet_agent::osfamily::debian') }
  end
end
