require 'spec_helper'

RSpec.describe 'puppet_agent', tag: 'win' do
  package_version = '1.10.100.1'
  global_params = {
    :package_version => package_version,
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

          it { is_expected.to contain_class('puppet_agent::windows::install') }
          it { is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(
              %r[#{Regexp.escape("\$Source=\'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{arch}.msi\'")}])
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end
      end

      context 'install_options =>' do
        describe 'OPTION1=value1 OPTION2=value2' do
          let(:params) { global_params.merge(
            {:install_options => ['OPTION1=value1','OPTION2=value2'],})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$InstallArgs='OPTION1=value1 OPTION2=value2'/)
          }
          it {
            is_expected.not_to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$InstallArgs='REINSTALLMODE="amus"'/)
          }
        end
      end

      context 'Default INSTALLMODE Option' do
        describe 'REINSTALLMODE=amus' do
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$InstallArgs='REINSTALLMODE="amus"'/)
          }
        end
      end

      context 'source =>' do
        describe 'https://alterernate.com/puppet-agent.msi' do
          let(:params) { global_params.merge(
            {:source => 'https://alternate.com/puppet-agent.msi',})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Source='C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi'/)
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Logfile='C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'C:/tmp/puppet-agent-x64.msi' do
          let(:params) { global_params.merge(
            {:source => 'C:/tmp/puppet-agent-x64.msi',})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Source='C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi'/)
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Logfile='C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe '\\\\garded\c$\puppet-agent-x64.msi' do
          let(:params) { global_params.merge(
            {:source => "\\\\garded\\c$\\puppet-agent-x64.msi",})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Source='C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi'/)
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Logfile='C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'/)
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'default source' do
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Source='C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi'/)
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Logfile='C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'/)
          }
          it {
            should contain_exec('install_puppet.ps1').with { {
                     'command' => 'C:\windows\sysnative\cmd.exe /c start /b C:\windows\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -NonInteractive -Command C:\tmp\install_puppet.ps1 42',
                   } }
          }
          it {
            is_expected.to_not contain_file('C:\tmp\puppet-agent.msi')
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'puppet:///puppet_agent/puppet-agent-1.1.0-x86.msi' do
          let(:params) { global_params.merge(
            {:source => 'puppet:///puppet_agent/puppet-agent-1.1.0-x86.msi'})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Source='C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi'/)
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
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$Source='C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-x86.msi'/
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
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$UseLockedFilesWorkaround=\$false/)
          }
        end

        describe 'specify false' do
          let(:params) { global_params.merge(
            {:msi_move_locked_files => false,})
          }

          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$UseLockedFilesWorkaround=\$false/)
          }
        end

        describe 'specify true' do
          let(:params) { global_params.merge(
            {:msi_move_locked_files => true,})
          }

          it {
            is_expected.to contain_file('C:\tmp\install_puppet.ps1').with_content(/\$UseLockedFilesWorkaround=\$true/)
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
