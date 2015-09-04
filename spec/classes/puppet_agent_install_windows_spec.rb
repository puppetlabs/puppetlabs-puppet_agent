require 'spec_helper'

describe 'puppet_agent', :if => (Puppet.version >= '3.8.0' and Puppet.version < '4.0.0') do
  {'5.1' => {:expect_arch => 'x86', :appdata => 'C:/Document and Settings/All Users/Application Data/Puppetlabs'},
   '6.1' => {:expect_arch => 'x64', :appdata => 'C:/ProgramData/Puppetlabs'}}.each do |kernelmajversion, values|
    context "Windows Kernelmajversion #{kernelmajversion}" do
      let(:facts) { {
        :architecture => 'x64',
        :env_temp_variable => 'C:\tmp',
        :kernelmajversion => kernelmajversion,
        :osfamily => 'windows',
        :puppet_confdir => "#{values[:appdata]}/puppet/etc",
        :mco_confdir => "#{values[:appdata]}/mcollective/etc",
        :puppet_agent_pid => 42,
        :system32 => 'C:\windows\sysnative',
      } }
      context 'is_pe' do
        before(:each) do
          # Need to mock the function pe_build_version
          pe_build_version = {}
          file = {}

          Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) {
            |args| pe_build_version.call()
          }
          Puppet::Parser::Functions.newfunction(:file, :type => :rvalue) {
            |args| file.call(args[0])
          }

          pe_build_version.stubs(:call).returns('4.0.0')
          file.stubs(:call).with('/opt/puppetlabs/puppet/VERSION').returns('1.2.1.1')
        end
        let(:params) {{ :is_pe => true }}
        it {
          is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
            %r[#{Regexp.escape("msiexec.exe /qn /norestart /i \"https://pm.puppetlabs.com/puppet-agent/4.0.0/1.2.1.1/repos/windows/puppet-agent-#{values[:expect_arch]}.msi\"")}])
        }
      end

      context 'source =>' do
        describe 'https://alterernate.com/puppet-agent.msi' do
          let(:params) { {
            :source => 'https://alternate.com/puppet-agent.msi',
          } }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "https:\/\/alternate.com\/puppet-agent.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/PID eq 42/)
          }
        end
        describe 'C:/tmp/puppet-agent-x64.msi' do
          let(:params) { {
            :source => 'C:/tmp/puppet-agent-x64.msi',
          } }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "C:\\tmp\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/PID eq 42/)
          }
        end
        describe 'C:\Temp/ Folder\puppet-agent-x64.msi' do
          let(:params) { {
            :source => 'C:\Temp/ Folder\puppet-agent-x64.msi',
          } }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "C:\\Temp Folder\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/PID eq 42/)
          }
        end
        describe 'C:/Temp/ Folder/puppet-agent-x64.msi' do
          let(:params) { {
            :source => 'C:/Temp/ Folder/puppet-agent-x64.msi',
          } }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "C:\\Temp Folder\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/PID eq 42/)
          }
        end
        describe '\\\\garded\c$\puppet-agent-x64.msi' do
          let(:params) { {
            :source => "\\\\garded\\c$\\puppet-agent-x64.msi",
          } }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "\\\\garded\\c\$\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/PID eq 42/)
          }
        end
        describe 'default source' do
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "https:\/\/downloads.puppetlabs.com\/windows\/puppet-agent-#{values[:expect_arch]}-latest\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer\.log"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/PID eq 42/)
          }
          it {
            should contain_exec('install_puppet.bat').with { {
              'command' => 'C:\windows\sysnative\cmd.exe /c start /b "C:\tmp\install_puppet.bat"',
            } }
          }
          it {
            is_expected.to_not contain_file('C:\tmp\puppet-agent.msi')
          }
        end
        describe 'puppet:///puppet_agent/puppet-agent-1.1.0-x86.msi' do
          let(:params) { {:source => 'puppet:///puppet_agent/puppet-agent-1.1.0-x86.msi'} }
          it {
            is_expected.to contain_file('C:\tmp\puppet-agent.msi').that_comes_before('File[C:\tmp\install_puppet.bat]')
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "C:\\tmp\\puppet-agent.msi"/
            )
          }
        end
      end

      context 'arch =>' do
        describe 'specify x86' do
          let(:params) { {:arch => 'x86'} }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
              /msiexec.exe \/qn \/norestart \/i "https:\/\/downloads.puppetlabs.com\/windows\/puppet-agent-x86-latest\.msi"/
            )
          }
        end

        describe 'try x64 on x86 system' do
          let(:facts) { {
            :osfamily => 'windows',
            :tmpdir => 'C:\tmp',
            :architecture => 'x86',
            :puppet_confdir => "#{values[:appdata]}/puppet/etc",
            :system32 => 'C:\windows\sysnative'
          } }
          let(:params) { {:arch => 'x64'} }
          it {
            expect { catalogue }.to raise_error(Puppet::Error, /unable to install x64 on a x86 system/)
          }
        end
      end
    end

    context 'rubyplatform' do
      facts = {
        :architecture => 'x64',
        :env_temp_variable => 'C:\tmp',
        :kernelmajversion => kernelmajversion,
        :osfamily => 'windows',
        :puppet_confdir => "#{values[:appdata]}/puppet/etc",
        :mco_confdir => "#{values[:appdata]}/mcollective/etc",
        :puppet_agent_pid => 42,
        :system32 => 'C:\windows\sysnative',
        :tmpdir => 'C:\tmp',
      }
      describe 'i386-ming32' do
        let(:facts) { facts.merge({:rubyplatform => 'i386-ming32'}) }
        it {
          is_expected.to contain_exec('install_puppet.bat').with { {
            'command' => 'C:\windows\sysnative\cmd.exe /c start /b C:\windows\system32\cmd.exe /c "C:\tmp\install_puppet.bat"',
          } }

        }
      end
      describe 'x86' do
        let(:facts) { facts.merge({:rubyplatform => 'x86_64'}) }
        it {
          is_expected.to contain_exec('install_puppet.bat').with { {
            'command' => 'C:\windows\sysnative\cmd.exe /c start /b C:\windows\sysnative\cmd.exe /c "C:\tmp\install_puppet.bat"',
          } }

        }
      end
    end
  end
end
