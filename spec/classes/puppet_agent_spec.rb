require 'spec_helper'

describe 'puppet_agent' do
  package_version = '6.5.4'
  global_params = {
    :package_version => package_version
  }
  def global_facts(facts, os)
    facts.merge(
      if os =~ /sles/
        {
          :is_pe => true,
          :operatingsystemmajrelease => facts[:operatingsystemrelease].split('.')[0],
        }
      elsif os =~ /solaris/
        {
          :is_pe => true,
        }
      elsif os =~ /windows/
        {
          :puppet_agent_appdata => 'C:\\ProgramData',
          :puppet_confdir    => 'C:\\ProgramData\\Puppetlabs\\puppet\\etc',
          :env_temp_variable => 'C:/tmp',
          :puppet_agent_pid  => 42,
          :puppet_config     => "C:\\puppet.conf",
        }
      else
        {}
      end).merge({:servername   => 'master.example.vm'})
  end

  context 'supported_operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          global_facts(facts, os)
        end

        context "when the aio_agent_version fact is undefined" do
          let(:facts) do
            global_facts(facts, os).merge({:aio_agent_version => nil})
          end

          it { should_not compile }
        end

        if os !~ /sles/ and os !~ /solaris/
          context 'package_version is undef by default' do
            let(:facts) do
              global_facts(facts, os).merge({:is_pe => false})
            end
            it { is_expected.to contain_class('puppet_agent').with_package_version(nil) }
          end
        end

        context 'package_version is undef if pe_compiling_server_aio_build is not defined' do
          let(:facts) do
            global_facts(facts, os).merge({:is_pe => true})
          end
          it { is_expected.to contain_class('puppet_agent').with_package_version(nil) }
        end

        context 'package_version is same as master when set to auto' do
          let(:params) {{ :package_version => 'auto' }}
          let(:node_params) {{ :serverversion => '7.6.5' }}
          it { is_expected.to contain_class('puppet_agent::prepare').with_package_version('7.6.5') }
          it { is_expected.to contain_class('puppet_agent::install').with_package_version('7.6.5') }
        end
      end
    end
  end

  context 'supported_operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          global_facts(facts, os).merge({:is_pe => true})
        end

        before(:each) do
          Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) {|args| '2000.0.0'}
          Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) {|args| '1.10.100'}
          Puppet::Parser::Functions.newfunction(:pe_compiling_server_version, :type => :rvalue) {|args| '2.20.200'}
        end

        context 'package_version is initialized automatically' do
          it { is_expected.to contain_class('puppet_agent').with_package_version(nil) }
        end

        context 'On a PE infrastructure node puppet_agent does nothing' do
          before(:each) do
            facts['pe_server_version'] = '2000.0.0'
          end
          it { is_expected.to_not contain_class('puppet_agent::prepare') }
          it { is_expected.to_not contain_class('puppet_agent::install') }
        end
      end
    end
  end

  context 'supported operating systems' do
    # Due to https://github.com/mcanevet/rspec-puppet-facts/issues/68
    # Need to ensure that Windows tests are set last, otherwise puppet tries
    # to load windows providers on non-windows platforms in error.
    os_list = on_supported_os.select { |os, _x| !(os =~ /windows/) }
    windows_list = on_supported_os.select{ |os, _x| os =~ /windows/ }
    os_list.merge!(windows_list)

    os_list.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          global_facts(facts, os)
        end

        before(:each) do
          if os =~ /sles/ || os =~ /solaris/
            # Need to mock the PE functions

            Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
              '2000.0.0'
            end

            Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
              '1.10.100'
            end
          end
        end

        context 'invalid package_versions' do
          ['1.3.5banana', '1.2', '10-q-5'].each do |version|
            let(:params) { { :package_version => version } }

            it { expect { catalogue }.to raise_error(/invalid version/) }
          end
        end

        context 'valid package_versions' do
          ['1.4.0.30.g886c5ab', '1.4.0', '1.4.0-10', '1.4.0.10'].each do |version|
            let(:params) { { :package_version => version } }

            it { is_expected.to compile.with_all_deps }
            it { expect { catalogue }.not_to raise_error }
          end
        end

        [{}, {:service_names => []}].each do |params|
          context "puppet_agent class with install_options with params: #{params}" do
            let(:params) { global_params.merge(
              {:install_options => ['OPTION1=value1','OPTION2=value2'],})
            }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('puppet_agent::install').with_install_options(['OPTION1=value1','OPTION2=value2']) }

            if os !~ /windows|solaris-10/
              it { is_expected.to contain_package('puppet-agent').with_install_options(['OPTION1=value1','OPTION2=value2']) }
            end

            if os =~ /solaris-10/
              it do
                is_expected.to contain_exec('solaris_install script')
                  .with_command(
                    '/usr/bin/ctrun -l none /tmp/solaris_install.sh 298 2>&1 > /tmp/solaris_install.log &'
                  )
              end
            end
          end
        end

        [{}, {:service_names => []}].each do |params|
          context "puppet_agent class without any parameters(params: #{params})" do
            let(:params) { params.merge(global_params) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('puppet_agent') }
            it { is_expected.to contain_class('puppet_agent::params') }
            it { is_expected.to contain_class('puppet_agent::prepare') }
            it { is_expected.to contain_class('puppet_agent::install').that_requires('Class[puppet_agent::prepare]') }

            if facts[:osfamily] == 'Debian'
              deb_package_version = package_version + '-1' + facts[:lsbdistcodename]
              it { is_expected.to contain_package('puppet-agent').with_ensure(deb_package_version) }
            elsif facts[:osfamily] == 'Solaris'
              if facts[:operatingsystemmajrelease] == '11'
                it { is_expected.to contain_package('puppet-agent').with_ensure('6.5.4') }
              else
                it do
                  is_expected.to contain_exec('solaris_install script')
                    .with_command(
                      '/usr/bin/ctrun -l none /tmp/solaris_install.sh 298 2>&1 > /tmp/solaris_install.log &'
                    )
                  end
              end
            elsif facts[:osfamily] == 'windows'
              # Windows does not contain any Package resources
            else
              it { is_expected.to contain_package('puppet-agent').with_ensure(package_version) }
            end

            unless os =~ /windows/
              if os !~ /sles/ && os !~ /solaris/
                it { is_expected.to contain_class('puppet_agent::service').that_requires('Class[puppet_agent::install]') }
              end
            end

            # Windows platform does not use Service resources; their services
            # are managed by the MSI installer.
            unless facts[:osfamily] == 'windows'
              if params[:service_names].nil? && os !~ /solaris|sles/
                it { is_expected.to contain_service('puppet') }
              else
                it { is_expected.to_not contain_service('puppet') }
                it { is_expected.to_not contain_service('mcollective') }
              end
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'puppet_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
        :puppet_ssldir   => '/dev/null/ssl',
        :puppet_config   => '/dev/null/puppet.conf',
        :architecture    => 'i386',
      }}
      let(:params) { global_params }

      it { is_expected.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
