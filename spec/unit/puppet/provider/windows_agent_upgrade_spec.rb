require 'spec_helper'

RSpec.describe Puppet::Type.type(:agent_upgrade).provider(:windows) do

  basic_args = {:name => 'Windows Upgrade'}
  before :each do
    Facter.stubs(:value).with(:osfamily).returns('windows')
    Facter.stubs(:value).with(:architecture).returns('x64')
  end

  def create_provider (args)
    resource = Puppet::Type::Agent_upgrade.new(args)

    Puppet::Type.type(:agent_upgrade).provider(:agent_upgrade).new(resource)
  end

  def stub_native_path(path)
    @provider.stubs(:native_path).with(path).returns(path.gsub('/', '\\'))
  end

  def stub_temp
    @provider.stubs(:new_logfile_path).returns('C:\\tmp\\puppet.log')
  end

  describe 'basic usage' do
    before :each do
      @provider = create_provider basic_args
    end

    it 'should provide puppet_agent_msi_filename' do
      expect(@provider.puppet_agent_msi_filename).to eq 'puppet-agent-x64-latest.msi'
    end

    it 'should build the get_command' do
      Process.stubs(:pid).returns 42
      @provider.stubs(:command).with(:powershell).returns('powershell.exe')
      stub_native_path 'powershell.exe'
      stub_temp

      expect(
        @provider.get_command
      ).to eq "cmd.exe /c \"\"powershell.exe\" -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -Command \"Wait-Process 42 -ErrorAction SilentlyContinue;msiexec /qn /i https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi /l*v C:\\tmp\\puppet.log \""
    end
  end


end
