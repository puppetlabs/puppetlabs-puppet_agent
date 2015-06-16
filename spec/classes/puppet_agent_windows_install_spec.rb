require 'spec_helper'

RSpec.describe 'puppet_agent', :unless => Puppet.version =~ /^(3\.7|4.\d+)\.\d+/ do

  if Puppet.version >= "4.0.0"
    it {
      is_expected.to_not contain_class('::puppet_agent::windows::install')
    }
  elsif Puppet.version >= "3.8.0"
    {'5.1' => {:expect_arch => 'x86', :appdata => 'C:/Document and Settings/All Users/Application Data/Puppetlabs'},
     '6.1' => {:expect_arch => 'x64', :appdata => 'C:/ProgramData/Puppetlabs'}}.each do |kernelmajversion, values|
      context "Windows Kernelmajversion #{kernelmajversion}" do
        let(:facts) { {
          :architecture => 'x64',
          :env_temp_variable => 'C:\tmp',
          :kernelmajversion => kernelmajversion,
          :osfamily => 'windows',
          :puppetversion => '3.8.0',
          :puppet_confdir => "#{values[:appdata]}/puppet/etc",
          :mco_confdir =>  "#{values[:appdata]}/mcollective/etc",
          :puppet_agent_pid => 42,
          :system32 => 'C:\windows\system32',
        } }
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
          describe 'default source' do
            let(:params) { {} }
            it {
              is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                               /msiexec.exe \/qn \/norestart \/i "https:\/\/downloads.puppetlabs.com\/windows\/puppet-agent-#{values[:expect_arch]}-latest\.msi"/)
              is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer\.log"/)
              is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/PID eq 42/)
            }
            it {
              should contain_exec('install_puppet.bat').with { {
                       'command' => 'C:\windows\system32\cmd.exe /c start /b "C:\tmp\install_puppet.bat"',
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
              :puppetversion => '3.8.0',
              :tmpdir => 'C:\tmp',
              :architecture => 'x86',
              :system32 => 'C:\windows\system32'
            } }
            let(:params) { {:arch => 'x64'} }
            it {
              expect { catalogue }.to raise_error(Puppet::Error, /Unable to install x64 on a x86 system/)
            }
          end
        end
      end
    end
  end
end
