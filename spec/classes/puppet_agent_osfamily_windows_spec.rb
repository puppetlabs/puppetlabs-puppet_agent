require 'spec_helper'

describe 'puppet_agent' do
  package_version = '1.10.100'
  pe_version = '2000.0.0'

  let(:params) { { package_version: package_version } }
  let(:version_file) { '/opt/puppetlabs/puppet/VERSION' }

  before(:each) do
    # Need to mock the PE functions
    Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
      pe_version
    end

    Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) do |_args|
      package_version
    end

    allow(Puppet::Util).to receive(:absolute_path?).and_call_original
    allow(Puppet::Util).to receive(:absolute_path?).with(version_file).and_return true
    allow(Puppet::FileSystem).to receive(:exist?).and_call_original
    allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).and_call_original
    allow(Puppet::FileSystem).to receive(:exist?).with(version_file).and_return true
    allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).with(version_file).and_return "1.10.100\n"
  end

  [['x64', 'x86_64'], ['x86', 'i386']].each do |arch, tag|
    describe "supported Windows #{arch} environment" do
      let(:appdata) { 'C:\ProgramData' }
      let(:facts) do
        {
          aio_agent_version: '1.0.0',
          clientcert: 'foo.example.vm',
          env_temp_variable: 'C:/tmp',
          is_pe: true,
          os: {
            architecture: arch,
            family: 'windows',
            name: 'windows',
            windows: {
              system32: 'C:\\Windows\\System32',
            },
          },
          puppet_agent_appdata: appdata,
          puppet_agent_pid: 42,
          puppet_confdir: "#{appdata}\\Puppetlabs\\puppet\\etc",
          servername: 'master.example.vm',
        }
      end

      it { is_expected.to contain_file("#{appdata}\\Puppetlabs") }
      it { is_expected.to contain_file("#{appdata}\\Puppetlabs\\packages") }
      it {
        is_expected.to contain_file("#{appdata}\\Puppetlabs\\packages\\puppet-agent-#{arch}.msi").with(
          'source' => "puppet:///pe_packages/#{pe_version}/windows-#{tag}/puppet-agent-#{arch}.msi",
        )
      }
    end
  end

  [['x64', 'x86_64'], ['x86', 'i386']].each do |arch, tag|
    describe "supported Windows #{arch} environment with auto" do
      server_version = '1.10.100'
      let(:params)  { { package_version: 'auto' } }
      let(:appdata) { 'C:\ProgramData' }
      let(:facts) do
        {
          aio_agent_version: '1.0.0',
          clientcert: 'foo.example.vm',
          env_temp_variable: 'C:/tmp',
          is_pe: true,
          os: {
            architecture: arch,
            family: 'windows',
            name: 'windows',
            windows: {
              system32: 'C:\\Windows\\System32',
            },
          },
          puppet_agent_appdata: appdata,
          puppet_agent_pid: 42,
          puppet_confdir: "#{appdata}\\Puppetlabs\\puppet\\etc",
          servername: 'master.example.vm',
          serverversion: server_version
        }
      end

      it { is_expected.to contain_file("#{appdata}\\Puppetlabs") }
      it { is_expected.to contain_file("#{appdata}\\Puppetlabs\\packages") }
      it {
        is_expected.to contain_file("#{appdata}\\Puppetlabs\\packages\\puppet-agent-#{arch}.msi").with(
          'source' => "puppet:///pe_packages/#{pe_version}/windows-#{tag}/puppet-agent-#{arch}.msi",
        )
      }
    end
  end

  describe 'supported Windows with fips mode enabled' do
    server_version = '1.10.100'
    let(:arch) { 'x64' }
    let(:tag) { 'x86_64' }
    let(:params)  { { package_version: 'auto' } }
    let(:appdata) { 'C:\ProgramData' }
    let(:facts) do
      {
        aio_agent_version: '1.0.0',
        clientcert: 'foo.example.vm',
        env_temp_variable: 'C:/tmp',
        is_pe: true,
        fips_enabled: true,
        os: {
          architecture: arch,
          family: 'windows',
          name: 'windows',
          windows: {
            system32: 'C:\\Windows\\System32',
          },
        },
        puppet_agent_appdata: appdata,
        puppet_agent_pid: 42,
        puppet_confdir: "#{appdata}\\Puppetlabs\\puppet\\etc",
        servername: 'master.example.vm',
        serverversion: server_version,
      }
    end

    it { is_expected.to contain_file("#{appdata}\\Puppetlabs") }
    it { is_expected.to contain_file("#{appdata}\\Puppetlabs\\packages") }
    it do
      is_expected.to contain_file("#{appdata}\\Puppetlabs\\packages\\puppet-agent-#{arch}.msi").with(
        'source' => "puppet:///pe_packages/#{pe_version}/windowsfips-#{tag}/puppet-agent-#{arch}.msi",
      )
    end
  end
end
