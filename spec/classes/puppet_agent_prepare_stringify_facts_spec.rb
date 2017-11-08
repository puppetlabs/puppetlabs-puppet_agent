require 'spec_helper'

describe 'puppet_agent::prepare::stringify_facts' do
  context 'supported operating system families' do
    %w[Debian RedHat SuSE].each do |osfamily|
      case osfamily
      when 'SuSE'
        os = 'SLES'
        osmajor = '10'
      else
        os = 'foo'
        osmajor = '42'
      end

      facts = {
        operatingsystem: os,
        operatingsystemmajrelease: osmajor,
        architecture: 'bar',
        osfamily: osfamily,
        lsbdistid: osfamily,
        lsbdistcodename: 'baz',
        mco_server_config: nil,
        mco_client_config: nil
      }

      context "on #{osfamily}" do
        if Puppet.version < '4.0.0'
          context 'on Puppet 3 or lower' do
            it {
              is_expected.to contain_ini_setting('puppet stringify_facts').with(
                ensure: 'present',
                value: false
              )
            }
          end
        else
          context 'on Puppet 4 or higher' do
            it {
              is_expected.to_not contain_ini_setting('puppet stringify_facts').with(
                ensure: 'present',
                value: false
              )
            }
          end
        end
      end
    end
  end
end
