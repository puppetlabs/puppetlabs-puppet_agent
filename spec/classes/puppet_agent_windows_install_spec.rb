require 'spec_helper'

RSpec.describe 'puppet_agent' do
  package_version = '1.2.1.1'
  global_params = {
    :package_version => package_version
  }

  {'5.1' => {:expect_arch => 'x86', :appdata => 'C:\Document and Settings\All Users\Application Data'},
   '6.1' => {:expect_arch => 'x64', :appdata => 'C:\ProgramData'}}.each do |kernelmajversion, values|
    context "Windows Kernelmajversion #{kernelmajversion}" do
      facts = {
        :architecture => 'x64',
        :env_temp_variable => 'C:\tmp',
        :kernelmajversion => kernelmajversion,
        :osfamily => 'windows',
        :puppetversion => '3.8.0',
        :puppet_confdir => "#{values[:appdata]}\\Puppetlabs\\puppet\\etc",
        :mco_confdir => "#{values[:appdata]}\\Puppetlabs\\mcollective\\etc",
        :puppet_agent_pid => 42,
        :system32 => 'C:\windows\sysnative',
        :common_appdata => values[:appdata],
      }

      let(:facts) { facts }
      let(:params) { global_params }

      context 'without aio_agent_version (FOSS)' do
        it { is_expected.to contain_class('puppet_agent::windows::install') }
      end

      context 'is_pe' do
        before(:each) do
          # Need to mock the PE functions

          Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
            '4.0.0'
          end

          Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
            package_version
          end
        end

        let(:facts) { facts.merge({:is_pe => true}) }

        it {
          is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
            %r[#{Regexp.escape("msiexec.exe /qn /norestart /i \"#{values[:appdata]}\\Puppetlabs\\packages\\puppet-agent-#{values[:expect_arch]}.msi\"")}])
        }

        context 'with up to date aio_agent_version matching server' do
          let(:facts) { facts.merge({
            :is_pe => true,
            :aio_agent_version => package_version
          })}

          it { is_expected.not_to contain_class('puppet_agent::windows::install') }
        end

        context 'with out of date aio_agent_version' do
          let(:facts) { facts.merge({
            :is_pe => true,
            :aio_agent_version => '1.2.0'
          })}

          it { is_expected.to contain_class('puppet_agent::windows::install') }
        end
      end

      context 'source =>' do
        describe 'https://alterernate.com/puppet-agent.msi' do
          let(:params) { global_params.merge(
            {:source => 'https://alternate.com/puppet-agent.msi',})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "https:\/\/alternate.com\/puppet-agent.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
          }
        end
        describe 'C:/tmp/puppet-agent-x64.msi' do
          let(:params) { global_params.merge(
            {:source => 'C:/tmp/puppet-agent-x64.msi',})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "C:\\tmp\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
          }
        end
        describe 'C:\Temp/ Folder\puppet-agent-x64.msi' do
          let(:params) { global_params.merge(
            {:source => 'C:\Temp/ Folder\puppet-agent-x64.msi',})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "C:\\Temp Folder\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
          }
        end
        describe 'C:/Temp/ Folder/puppet-agent-x64.msi' do
          let(:params) { global_params.merge(
            {:source => 'C:/Temp/ Folder/puppet-agent-x64.msi',})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "C:\\Temp Folder\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
          }
        end
        describe '\\\\garded\c$\puppet-agent-x64.msi' do
          let(:params) { global_params.merge(
            {:source => "\\\\garded\\c$\\puppet-agent-x64.msi",})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "\\\\garded\\c\$\\puppet-agent-x64\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer.log"/)
          }
        end
        describe 'default source' do
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "https:\/\/downloads.puppetlabs.com\/windows\/puppet-agent-#{values[:expect_arch]}-#{package_version}\.msi"/)
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(/\/l\*v "C:\\tmp\\puppet-\d+_\d+_\d+-\d+_\d+-installer\.log"/)
          }
          it {
            should contain_exec('install_puppet.bat').with { {
                     'command' => 'C:\windows\sysnative\cmd.exe /c start /b "C:\tmp\install_puppet.bat" 42',
                   } }
          }
          it {
            is_expected.to_not contain_file('C:\tmp\puppet-agent.msi')
          }
        end
        describe 'puppet:///puppet_agent/puppet-agent-1.1.0-x86.msi' do
          let(:params) { global_params.merge(
            {:source => 'puppet:///puppet_agent/puppet-agent-1.1.0-x86.msi'})
          }
          it {
            is_expected.to contain_file('C:\tmp\puppet-agent.msi').with_before('File[C:\tmp\install_puppet.bat]')
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "C:\\tmp\\puppet-agent.msi"/
                           )
          }
        end
      end
      context 'arch =>' do
        describe 'specify x86' do
          let(:params) { global_params.merge(
            {:arch => 'x86'})
          }
          it {
            is_expected.to contain_file('C:\tmp\install_puppet.bat').with_content(
                             /msiexec.exe \/qn \/norestart \/i "https:\/\/downloads.puppetlabs.com\/windows\/puppet-agent-x86-#{package_version}\.msi"/
                           )
          }
        end

        describe 'try x64 on x86 system' do
          let(:facts) { {
            :osfamily => 'windows',
            :puppetversion => '3.8.0',
            :tmpdir => 'C:\tmp',
            :architecture => 'x86',
            :system32 => 'C:\windows\sysnative',
            :puppet_confdir => "#{values[:appdata]}\\Puppetlabs\\puppet\\etc",
            :mco_confdir => "#{values[:appdata]}\\Puppetlabs\\mcollective\\etc",
          } }
          let(:params) { global_params.merge(
            {:arch => 'x64'})
          }
          it {
            expect { catalogue }.to raise_error(Puppet::Error, /Unable to install x64 on a x86 system/)
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
        :puppetversion => '3.8.0',
        :puppet_confdir => "#{values[:appdata]}/PuppetLabs/puppet/etc",
        :mco_confdir => "#{values[:appdata]}/PuppetLabs/mcollective/etc",
        :puppet_agent_pid => 42,
        :system32 => 'C:\windows\sysnative',
        :tmpdir => 'C:\tmp',
      }
      describe 'i386-ming32' do
        let(:facts) { facts.merge({:rubyplatform => 'i386-ming32'}) }
        let(:params) { global_params }
        it {
          is_expected.to contain_exec('install_puppet.bat').with { {
                           'command' => 'C:\windows\sysnative\cmd.exe /c start /b C:\windows\system32\cmd.exe /c "C:\tmp\install_puppet.bat" 42',
                         } }

        }
      end
      describe 'x86' do
        let(:facts) { facts.merge({:rubyplatform => 'x86_64'}) }
        let(:params) { global_params }
        it {
          is_expected.to contain_exec('install_puppet.bat').with { {
                           'command' => 'C:\windows\sysnative\cmd.exe /c start /b C:\windows\sysnative\cmd.exe /c "C:\tmp\install_puppet.bat" 42',
                         } }

        }
      end
    end
  end
end
