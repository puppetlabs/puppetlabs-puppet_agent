require 'spec_helper'

describe 'puppet_agent' do
  master_package_version = '1.10.100'
  before(:each) do
    # Need to mock the PE functions
    Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
      '2000.0.0'
    end

    Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) do |_args|
      master_package_version
    end

    allow(Puppet::FileSystem).to receive(:exist?).and_call_original
    allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).and_call_original
    allow(Puppet::FileSystem).to receive(:exist?).with('/opt/puppetlabs/puppet/VERSION').and_return true
    allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).with('/opt/puppetlabs/puppet/VERSION').and_return "5.10.200\n"
  end

  package_version = '1.10.100'

  facts = {
    is_pe: true,
    osfamily: 'Darwin',
    operatingsystem: 'Darwin',
    macosx_productversion_major: '10.13',
    architecture: 'x86_64',
    servername: 'master.example.vm',
    clientcert: 'foo.example.vm',
    env_temp_variable: '/tmp',
    puppet_agent_pid: 42
  }

  describe 'supported environment' do
    let(:params) { { package_version: package_version } }

    context 'when running a supported OSX' do
      ['osx-10.15-x86_64', 'osx-11-x86_64', 'osx-12-x86_64'].each do |tag|
        context "on #{tag} with no aio_version" do
          let(:osmajor) { tag.split('-')[1] }

          let(:facts) do
            facts.merge({
                          is_pe: true,
                          aio_agent_version: '1.10.99',
                          platform_tag: tag,
                          macosx_productversion_major: osmajor
                        })
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/opt/puppetlabs') }
          it { is_expected.to contain_file('/opt/puppetlabs/packages') }
          it { is_expected.to contain_file("/opt/puppetlabs/packages/puppet-agent-#{package_version}-1.osx#{osmajor}.dmg") }
          it { is_expected.to contain_file('/tmp/osx_install.sh') }
          it { is_expected.to contain_exec('osx_install script') }
          it { is_expected.to contain_class('puppet_agent::osfamily::darwin') }

          context 'aio_agent_version is out of date' do
            let(:facts) do
              facts.merge({
                            aio_agent_version: '0.0.1'
                          })
            end

            it { is_expected.not_to contain_exec('forget puppet-agent') }
          end

          it { is_expected.not_to contain_exec('forget puppet-agent') }
        end
      end
    end
  end

  describe 'when using a user defined source' do
    let(:params) do
      {
        package_version: '5.10.100.1',
        collection: 'puppet5',
        source: 'https://fake-pe-master.com',
      }
    end
    let(:facts) do
      facts.merge({
                    is_pe: true,
                    aio_agent_version: '1.10.99',
                    platform_tag: 'osx-10.13-x86_64',
                    macosx_productversion_major: '10.13'
                  })
    end

    it { is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-5.10.100.1-1.osx10.13.dmg').with_source('https://fake-pe-master.com/packages/2000.0.0/osx-10.13-x86_64/puppet-agent-5.10.100.1-1.osx10.13.dmg') }
  end

  describe 'when using package_version auto' do
    let(:params) do
      {
        package_version: 'auto',
      }
    end
    let(:facts) do
      facts.merge({
                    is_pe: true,
                    aio_agent_version: '1.10.99',
                    platform_tag: 'osx-10.13-x86_64',
                    macosx_productversion_major: '10.13',
                    serverversion: '5.10.200'
                  })
    end

    it { is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-5.10.200-1.osx10.13.dmg').with_source('puppet:///pe_packages/2000.0.0/osx-10.13-x86_64/puppet-agent-5.10.200-1.osx10.13.dmg') }
  end

  describe 'when using package_version auto with MacOS 11(two numbers version productversion)' do
    let(:params) do
      {
        package_version: 'auto',
      }
    end
    let(:facts) do
      facts.merge({
                    is_pe: true,
                    aio_agent_version: '1.10.99',
                    platform_tag: 'osx-11-x86_64',
                    macosx_productversion_major: '11.2',
                    serverversion: '5.10.200'
                  })
    end

    it { is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-5.10.200-1.osx11.dmg').with_source('puppet:///pe_packages/2000.0.0/osx-11-x86_64/puppet-agent-5.10.200-1.osx11.dmg') }
  end

  describe 'when using package_version auto with MacOS 11(one number version productversion)' do
    let(:params) do
      {
        package_version: 'auto',
      }
    end
    let(:facts) do
      facts.merge({
                    is_pe: true,
                    aio_agent_version: '1.10.99',
                    platform_tag: 'osx-11-x86_64',
                    macosx_productversion_major: '11',
                    serverversion: '5.10.200'
                  })
    end

    it { is_expected.to contain_file('/opt/puppetlabs/packages/puppet-agent-5.10.200-1.osx11.dmg').with_source('puppet:///pe_packages/2000.0.0/osx-11-x86_64/puppet-agent-5.10.200-1.osx11.dmg') }
  end
end
