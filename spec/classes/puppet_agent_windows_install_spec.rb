require 'spec_helper'

RSpec.describe 'puppet_agent', tag: 'win' do
  package_version = '5.10.100.1'
  collection = 'puppet5'
  global_params = {
    :package_version => package_version,
    :collection      => collection
  }
  ['x86', 'x64'].each do |arch|
    context "Windows arch #{arch}" do
      facts = {
        :architecture => arch,
        :env_temp_variable => 'C:/tmp',
        :osfamily => 'windows',
        :puppetversion => '4.10.100',
        :puppet_confdir => "C:\\ProgramData\\Puppetlabs\\puppet\\etc",
        :puppet_agent_pid => 42,
        :system32 => 'C:\windows\sysnative',
        :puppet_agent_appdata => "C:\\ProgramData",
      }

      let(:facts) { facts }
      let(:params) { global_params }

      context 'is_pe' do
        before(:each) do
          # Need to mock the PE functions
          Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
            '4.10.100'
          end

          Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
            package_version
          end
        end

        let(:facts) { facts.merge({:is_pe => true}) }

        context 'with up to date aio_agent_version matching server' do
          let(:facts) { facts.merge({
            :is_pe => true,
            :aio_agent_version => package_version
          })}

          it { is_expected.not_to contain_file('c:\tmp\install_puppet.bat') }
          it { is_expected.not_to contain_exec('fix inheritable SYSTEM perms') }
        end

        context 'with equal package_version containing git sha' do
          let(:facts) { facts.merge({
            :is_pe => true,
            :aio_agent_version => package_version
          })}

          let(:params) {
            global_params.merge(:package_version => "#{package_version}.g886c5ab")
          }

          it { is_expected.not_to contain_file('c:\tmp\install_puppet.bat') }
          it { is_expected.not_to contain_exec('install_puppet.bat') }
        end

        context 'with out of date aio_agent_version' do
          let(:facts) { facts.merge({
            :is_pe => true,
            :aio_agent_version => '1.10.0'
          })}

          it { is_expected.to contain_class('puppet_agent::install::windows') }
          it { is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Source \'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{arch}.msi\'/) }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end
      end

      context 'install_options =>' do
        describe 'OPTION1=value1 OPTION2=value2' do
          let(:params) { global_params.merge(
            {:install_options => ['OPTION1=value1','OPTION2="value2"'],})
          }
          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-InstallArgs 'OPTION1=value1 OPTION2="""value2"""'/)
          }
          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(/\-InstallArgs 'REINSTALLMODE="""amus"""'/)
          }
        end
      end

      context 'Default INSTALLMODE Option' do
        describe 'REINSTALLMODE=amus' do
          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-InstallArgs 'REINSTALLMODE="""amus"""'/)
          }
        end
      end

      context 'absolute_source =>' do
        describe 'https://alterernate.com/puppet-agent-999.1-x64.msi' do
          let(:params) { global_params.merge(
            {:absolute_source => 'https://alternate.com/puppet-agent-999.1-x64.msi',})
          }
          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.1-x64.msi').with_source('https://alternate.com/puppet-agent-999.1-x64.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.1-x64\.msi'/)
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Logfile 'C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'C:/tmp/puppet-agent-999.2-x64.msi' do
          let(:params) { global_params.merge(
            {:absolute_source => 'C:/tmp/puppet-agent-999.2-x64.msi',})
          }
          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.2-x64.msi').with_source('C:/tmp/puppet-agent-999.2-x64.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.2-x64\.msi'/)
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Logfile 'C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe '\\\\garded\c$\puppet-agent-999.3-x64.msi' do
          let(:params) { global_params.merge(
            {:absolute_source => "\\\\garded\\c$\\puppet-agent-999.3-x64.msi",})
          }
          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.3-x64.msi').with_source('\\\\garded\c$\puppet-agent-999.3-x64.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.3-x64\.msi'/)
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Logfile 'C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'default source' do
          it {
            is_expected.to contain_file("C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi")
                              .with_source("https://downloads.puppet.com/windows/#{collection}/puppet-agent-#{package_version}-#{arch}.msi")
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'puppet:///puppet_agent/puppet-agent-999.4-x86.msi' do
          let(:params) { global_params.merge(
            {:absolute_source => 'puppet:///puppet_agent/puppet-agent-999.4-x86.msi'})
          }
          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.4-x86.msi').with_source('puppet:///puppet_agent/puppet-agent-999.4-x86.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.4-x86\.msi'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end
      end

      context 'arch =>' do
        describe 'specify x86' do
          let(:params) { global_params.merge(
            {:arch => 'x86'})
          }
          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-x86.msi'/
                           )
          }
        end

        describe 'try x64 on x86 system' do
          let(:facts) { {
            :osfamily => 'windows',
            :puppetversion => '4.10.100',
            :tmpdir => 'C:\tmp',
            :architecture => 'x86',
            :system32 => 'C:\windows\sysnative',
            :puppet_confdir => "C:\\ProgramData\\Puppetlabs\\puppet\\etc",
          } }

          let(:params) { global_params.merge(
            {:arch => 'x64'})
          }

          it {
            expect { catalogue }.to raise_error(Puppet::Error, /Unable to install x64 on a x86 system/)
          }
        end
      end

      context 'msi_move_locked_files =>' do
        describe 'default' do
          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(/\-UseLockedFilesWorkaround/)
          }
        end

        describe 'specify false' do
          let(:params) { global_params.merge(
            {:msi_move_locked_files => false,})
          }

          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(/\-UseLockedFilesWorkaround/)
          }
        end

        describe 'specify true' do
          let(:params) { global_params.merge(
            {:msi_move_locked_files => true,})
          }

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(/\-UseLockedFilesWorkaround/)
          }
        end
      end
    end

    context 'rubyplatform' do
      facts = {
        :architecture => 'x64',
        :env_temp_variable => 'C:/tmp',
        :osfamily => 'windows',
        :puppetversion => '3.8.0',
        :puppet_confdir => "C:\\ProgramData/PuppetLabs/puppet/etc",
        :puppet_agent_pid => 42,
        :system32 => 'C:\windows\sysnative',
        :tmpdir => 'C:\tmp',
      }

      describe 'i386-ming32' do
        let(:facts) { facts.merge({:rubyplatform => 'i386-ming32'}) }
        let(:params) { global_params }

        it {
          is_expected.to contain_exec('install_puppet.ps1').with { {
                           'command' => 'C:\windows\sysnative\cmd.exe /c start /b C:\windows\system32\cmd.exe /c "C:\tmp\install_puppet.ps1" 42',
                         } }
        }

        it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
      end

      describe 'x86' do
        let(:facts) { facts.merge({:rubyplatform => 'x86_64'}) }
        let(:params) { global_params }

        it {
          is_expected.to contain_exec('install_puppet.ps1').with { {
                           'command' => 'C:\windows\sysnative\cmd.exe /c start /b C:\windows\sysnative\cmd.exe /c "C:\tmp\install_puppet.ps1" 42',
                         } }
        }

        it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
      end
    end
  end
end
