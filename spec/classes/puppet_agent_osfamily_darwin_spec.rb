require 'spec_helper'

describe 'puppet_agent' do
  master_package_version = '1.3.5'
  before(:each) do
    # Need to mock the PE functions
    Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
      "4.0.0"
    end

    Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
      master_package_version
    end
  end

  if Puppet.version >= "4.0.0"
    package_version = '1.2.5'
    let(:params) do
      {
        :package_version => package_version
      }
    end
  else
    # Default to PE master package version in 3.8
    package_version = master_package_version
  end

  facts = {
    :is_pe                       => true,
    :osfamily                    => 'Darwin',
    :operatingsystem             => 'Darwin',
    :macosx_productversion_major => '10.9',
    :architecture                => 'x86_64',
    :servername                  => 'master.example.vm',
    :clientcert                  => 'foo.example.vm',
  }

  describe 'unsupported environment' do
    context "when OSX 10.8" do
      let(:facts) do
        facts.merge({
          :platform_tag                => "osx-10.8-x86_64",
          :macosx_productversion_major => '10.8',
        })
      end

      it { expect { catalogue }.to raise_error(/not supported/) }
    end
  end

  describe 'supported environment' do
    context "when running a supported OSX" do
      ["osx-10.9-x86_64", "osx-10.10-x86_64", "osx-10.11-x86_64"].each do |tag|
        context "on #{tag} with no aio_version" do
          let(:osmajor) { tag.split('-')[1] }

          let(:facts) do
            facts.merge({
              :is_pe                       => true,
              :platform_tag                => tag,
              :macosx_productversion_major => osmajor,
            })
          end

          it { should compile.with_all_deps }
          it { is_expected.to contain_file('/opt/puppetlabs') }
          it { is_expected.to contain_file('/opt/puppetlabs/packages') }
          it { is_expected.to contain_file("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.osx#{osmajor}.dmg") }
          it { is_expected.to contain_package('puppet-agent').with_ensure('present') }
          it { is_expected.to contain_package('puppet-agent').with_source("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.osx#{osmajor}.dmg") }
          it { is_expected.to contain_class('puppet_agent::install::remove_packages') }
          it { is_expected.to contain_class('puppet_agent::install::remove_packages_osx') }
          it { is_expected.to contain_class("puppet_agent::osfamily::darwin") }

          if Puppet.version < "4.0.0"
            [
              'pe-augeas',
              'pe-ruby-augeas',
              'pe-openssl',
              'pe-ruby',
              'pe-cfpropertylist',
              'pe-facter',
              'pe-puppet',
              'pe-mcollective',
              'pe-hiera',
              'pe-puppet-enterprise-release',
              'pe-stomp',
              'pe-libyaml',
              'pe-ruby-rgen',
              'pe-deep-merge',
              'pe-ruby-shadow',
            ].each do |package|
              it { is_expected.to contain_exec("forget #{package}").with_command("/usr/sbin/pkgutil --forget com.puppetlabs.#{package}") }
              it { is_expected.to contain_exec("forget #{package}").with_require('File[/opt/puppet]') }
            end
          else
            context 'aio_agent_version is out of date' do
              let(:facts) do
                facts.merge({
                  :aio_agent_version => '1.0.0'
                })
              end

              it { is_expected.not_to contain_exec('forget puppet-agent') }
            end

            it { is_expected.not_to contain_exec('forget puppet-agent') }
          end
        end
      end
    end
  end
end
