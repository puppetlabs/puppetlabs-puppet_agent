require 'spec_helper'

RSpec.describe 'puppet_agent', tag: 'win' do
  package_version = '5.10.100.1'
  collection = 'puppet5'
  global_params = {
    package_version: package_version,
    collection: collection
  }
  ['x86', 'x64'].each do |arch|
    context "Windows arch #{arch}" do
      facts = {
        env_temp_variable: 'C:/tmp',
        os: {
          architecture: arch,
          family: 'windows',
          windows: {
            system32: 'C:\windows\sysnative',
          },
        },
        puppet_agent_appdata: 'C:\ProgramData',
        puppet_agent_pid: 42,
        puppet_confdir: 'C:\ProgramData\Puppetlabs\puppet\etc',
        puppetversion: '4.10.100',
      }

      let(:facts) { facts }
      let(:params) { global_params }

      context 'is_pe' do
        before(:each) do
          # Need to mock the PE functions
          Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
            '4.10.100'
          end

          Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, type: :rvalue) do |_args|
            package_version
          end
        end

        let(:facts) { facts.merge({ is_pe: true }) }

        context 'with up to date aio_agent_version matching server' do
          let(:facts) do
            facts.merge({
                          is_pe: true,
                          aio_agent_version: package_version
                        })
          end

          it { is_expected.not_to contain_file('c:\tmp\install_puppet.bat') }
          it { is_expected.not_to contain_exec('prerequisites_check.ps1') }
          it { is_expected.not_to contain_exec('fix inheritable SYSTEM perms') }
        end

        context 'with equal package_version containing git sha' do
          let(:facts) do
            facts.merge({
                          is_pe: true,
                          aio_agent_version: package_version
                        })
          end

          let(:params) do
            global_params.merge(package_version: "#{package_version}.g886c5ab")
          end

          it { is_expected.not_to contain_file('c:\tmp\install_puppet.bat') }
          it { is_expected.not_to contain_exec('install_puppet.bat') }
          it { is_expected.not_to contain_exec('prerequisites_check.ps1') }
        end

        context 'with out of date aio_agent_version' do
          let(:facts) do
            facts.merge({
                          is_pe: true,
                          aio_agent_version: '1.10.0'
                        })
          end

          it { is_expected.to contain_class('puppet_agent::install::windows') }
          it { is_expected.to contain_exec('prerequisites_check.ps1').with_command(%r{\ #{package_version} C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{arch}.msi C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log}) }
          it { is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Source \'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{arch}.msi\'}) }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end
      end

      context 'package_version =>' do
        describe '5.6.7' do
          let(:params) do
            global_params.merge(
            { package_version: '5.6.7' },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_unless(%r{\-Command \{\$CurrentVersion = \[string\]\(facter.bat aio_agent_version\);})
            is_expected.to contain_exec('install_puppet.ps1').with_unless(%r{\-Command.*if \(\$CurrentVersion \-eq '5\.6\.7'\) \{ +exit 0; *\} *exit 1; \}\.Invoke\(\)})
          }
        end
      end
      context 'install_options =>' do
        describe 'OPTION1=value1 OPTION2=value2' do
          let(:params) do
            global_params.merge(
            { install_options: ['OPTION1=value1', 'OPTION2="value2"'], },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-InstallArgs 'OPTION1=value1 OPTION2="""value2"""'})
          }
          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-InstallArgs 'REINSTALLMODE="""amus"""'})
          }
        end
      end

      context 'Default INSTALLMODE Option' do
        describe 'REINSTALLMODE=amus' do
          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-InstallArgs 'REINSTALLMODE="""amus"""'})
          }
        end
      end

      context 'absolute_source =>' do
        describe 'https://alterernate.com/puppet-agent-999.1-x64.msi' do
          let(:params) do
            global_params.merge(
            { absolute_source: 'https://alternate.com/puppet-agent-999.1-x64.msi', },
          )
          end

          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.1-x64.msi').with_source('https://alternate.com/puppet-agent-999.1-x64.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.1-x64\.msi'})
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Logfile 'C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'})
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'C:/tmp/puppet-agent-999.2-x64.msi' do
          let(:params) do
            global_params.merge(
            { absolute_source: 'C:/tmp/puppet-agent-999.2-x64.msi', },
          )
          end

          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.2-x64.msi').with_source('C:/tmp/puppet-agent-999.2-x64.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.2-x64\.msi'})
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Logfile 'C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'})
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe '\\garded\c$\puppet-agent-999.3-x64.msi' do
          let(:params) do
            global_params.merge(
            { absolute_source: '\\garded\c$\puppet-agent-999.3-x64.msi', },
          )
          end

          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.3-x64.msi').with_source('\\garded\c$\puppet-agent-999.3-x64.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.3-x64\.msi'})
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Logfile 'C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log'})
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'default source' do
          it {
            is_expected.to contain_file("C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi")
              .with_source("https://downloads.puppet.com/windows/#{collection}/puppet-agent-#{package_version}-#{arch}.msi")
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-#{arch}\.msi'})
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end

        describe 'puppet:///puppet_agent/puppet-agent-999.4-x86.msi' do
          let(:params) do
            global_params.merge(
            { absolute_source: 'puppet:///puppet_agent/puppet-agent-999.4-x86.msi' },
          )
          end

          it {
            is_expected.to contain_file('C:\ProgramData\Puppetlabs\packages\puppet-agent-999.4-x86.msi').with_source('puppet:///puppet_agent/puppet-agent-999.4-x86.msi')
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-999.4-x86\.msi'})
          }
          it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
        end
      end

      context 'arch =>' do
        describe 'specify x86' do
          let(:params) do
            global_params.merge(
            { arch: 'x86' },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-Source 'C:\\ProgramData\\Puppetlabs\\packages\\puppet-agent-#{package_version}-x86.msi'})
          }
        end

        describe 'try x64 on x86 system' do
          let(:facts) do
            {
              os: {
                architecture: 'x86',
                family: 'windows',
                windows: {
                  system32: 'C:\windows\sysnative',
                },
              },
              puppet_confdir: 'C:\\ProgramData\\Puppetlabs\\puppet\\etc',
              puppetversion: '4.10.100',
              tmpdir: 'C:\tmp',
            }
          end

          let(:params) do
            global_params.merge(
            { arch: 'x64' },
          )
          end

          it {
            expect { catalogue }.to raise_error(Puppet::Error, %r{Unable to install x64 on a x86 system})
          }
        end
      end

      context 'msi_move_locked_files =>' do
        describe 'default' do
          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-UseLockedFilesWorkaround})
          }
        end

        describe 'specify false' do
          let(:params) do
            global_params.merge(
            { msi_move_locked_files: false, },
          )
          end

          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-UseLockedFilesWorkaround})
          }
        end

        describe 'specify true with puppet 5.5.16' do
          let(:params) do
            global_params.merge(
            { msi_move_locked_files: true,
             package_version: '5.5.16',  },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-UseLockedFilesWorkaround})
          }
        end

        describe 'specify true with puppet 5.5.17' do
          let(:params) do
            global_params.merge(
            { msi_move_locked_files: true,
             package_version: '5.5.17',  },
          )
          end

          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-UseLockedFilesWorkaround})
          }
        end

        describe 'specify true with puppet 6.7.0' do
          let(:params) do
            global_params.merge(
            { msi_move_locked_files: true,
             package_version: '6.7.0',  },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-UseLockedFilesWorkaround})
          }
        end

        describe 'specify true with puppet 6.8.0' do
          let(:params) do
            global_params.merge(
            { msi_move_locked_files: true,
             package_version: '6.8.0',  },
          )
          end

          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-UseLockedFilesWorkaround})
          }
        end
      end

      context 'wait_for_pxp_agent_exit =>' do
        describe 'default' do
          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-WaitForPXPAgentExit})
          }
        end

        describe 'specify timeout value of 5 minutes' do
          let(:params) do
            global_params.merge(
            { wait_for_pxp_agent_exit: 300_000, },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-WaitForPXPAgentExit 300000})
          }
        end
      end

      context 'wait_for_puppet_run =>' do
        describe 'default' do
          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-WaitForPuppetRun})
          }
        end

        describe 'specify timeout of 10 minutes' do
          let(:params) do
            global_params.merge(
            { wait_for_puppet_run: 600_000, },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-WaitForPuppetRun 600000})
          }
        end
      end

      context 'wait_for_puppet_run =>' do
        describe 'default' do
          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-WaitForPuppetRun})
          }
        end

        describe 'specify false' do
          let(:params) do
            global_params.merge(
            { wait_for_puppet_run: false, },
          )
          end

          it {
            is_expected.not_to contain_exec('install_puppet.ps1').with_command(%r{\-WaitForPuppetRun})
          }
        end

        describe 'specify true' do
          let(:params) do
            global_params.merge(
            { wait_for_puppet_run: true },
          )
          end

          it {
            is_expected.to contain_exec('install_puppet.ps1').with_command(%r{\-WaitForPuppetRun})
          }
        end
      end
    end

    context 'rubyplatform' do
      facts = {
        env_temp_variable: 'C:/tmp',
        os: {
          architecture: 'x64',
          family: 'windows',
          windows: {
            system32: 'C:\windows\sysnative',
          },
        },
        puppet_agent_pid: 42,
        puppet_confdir: 'C:/ProgramData/PuppetLabs/puppet/etc',
        puppetversion: '3.8.0',
        tmpdir: 'C:\tmp',
      }

      describe 'i386-ming32' do
        let(:facts) { facts.merge({ ruby: { platform: 'i386-ming32', }, }) }
        let(:params) { global_params }

        it {
          is_expected.to contain_exec('install_puppet.ps1')
            .with_command(%r{C:\\windows\\sysnative\\cmd.exe\s/S\s/c\sstart\s/b\sC:\\windows\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe
            \s+-ExecutionPolicy\sBypass\s+-NoProfile\s+-NoLogo\s+-NonInteractive\s+-Command\sC:\\tmp\\install_puppet.ps1
            \s+-PuppetPID\s42}x)
        }

        it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
      end

      describe 'x86' do
        let(:facts) { facts.merge({ ruby: { platform: 'x86_64', }, }) }
        let(:params) { global_params }

        it {
          is_expected.to contain_exec('install_puppet.ps1')
            .with_command(%r{C:\\windows\\sysnative\\cmd.exe\s/S\s/c\sstart\s/b\sC:\\windows\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe
              \s+-ExecutionPolicy\sBypass\s+-NoProfile\s+-NoLogo\s+-NonInteractive\s+-Command\sC:\\tmp\\install_puppet.ps1
              \s+-PuppetPID\s42}x)
        }

        it { is_expected.to contain_exec('fix inheritable SYSTEM perms') }
      end
    end
  end
end
