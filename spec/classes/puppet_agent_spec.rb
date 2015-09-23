require 'spec_helper'

describe 'puppet_agent' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          if os =~ /sles/
            facts.merge({
              :is_pe => true,
              :operatingsystemmajrelease => facts[:operatingsystemrelease].split('.')[0],
            })
          else
            facts
          end
        end

        before(:each) do
          if os =~ /sles/
            # Need to mock the PE functions

            Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
              '4.0.0'
            end

            Puppet::Parser::Functions.newfunction(:pe_compiling_server_aio_build, :type => :rvalue) do |args|
              '1.2.5'
            end
          end
        end

        if Puppet.version < "3.8.0"
          it { expect { is_expected.to contain_package('puppet_agent') }.to raise_error(Puppet::Error, /upgrading requires Puppet 3.8/) }
        else
          [{}, {:service_names => []}].each do |params|
            context "puppet_agent class without any parameters" do
              let(:params) { params }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_class('puppet_agent') }
              it { is_expected.to contain_class('puppet_agent::params') }
              if Puppet.version < "4.0.0"
                it { is_expected.to contain_class('puppet_agent::prepare') }
                it { is_expected.to contain_class('puppet_agent::install').that_comes_before('puppet_agent::service') }
                it { is_expected.to contain_class('puppet_agent::service') }

                if params[:service_names].nil?
                  it { is_expected.to contain_service('puppet') }
                  it { is_expected.to contain_service('mcollective') }
                else
                  it { is_expected.to_not contain_service('puppet') }
                  it { is_expected.to_not contain_service('mcollective') }
                end
                it { is_expected.to contain_package('puppet-agent').with_ensure('present') }
              else
                it { is_expected.to_not contain_service('puppet') }
                it { is_expected.to_not contain_service('mcollective') }
                it { is_expected.to_not contain_package('puppet-agent') }
              end
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system', :unless => Puppet.version < "3.8.0" || Puppet.version >= "4.0.0" do
    describe 'puppet_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
        :puppet_ssldir   => '/dev/null/ssl',
        :puppet_config   => '/dev/null/puppet.conf',
        :architecture    => 'i386',
      }}

      it { expect { is_expected.to contain_package('puppet_agent') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
