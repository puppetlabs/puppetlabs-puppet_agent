require 'spec_helper'

base_facts = {
  :osfamily               => 'RedHat',
  :puppet_ssldir          => '/dev/null/ssl',
  :puppet_config          => '/dev/null/puppet.conf',
  :mcollective_configured => false,
}

describe 'agent_upgrade::prepare' do
  context 'on Linux' do
    let(:facts) { base_facts }

    [true, false].each do |mcollective_configured|
      context "with mcollective_configured = #{mcollective_configured}" do
        let(:facts) { base_facts.merge({:mcollective_configured => mcollective_configured}) }

        if mcollective_configured
          it { is_expected.to contain_file('/etc/puppetlabs/mcollective').with_ensure('directory') }
          it { is_expected.to contain_file('/etc/puppetlabs/mcollective/server.cfg').with({
            'ensure' => 'file',
            'source' => '/etc/mcollective/server.cfg',
          }) }
        else
          it { is_expected.to_not contain_file('/etc/puppetlabs/mcollective') }
        end
      end
    end

    ['/etc/puppetlabs', '/etc/puppetlabs/puppet'].each do |dir|
      it { is_expected.to contain_file(dir).with_ensure('directory') }
    end

    it { is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf').with({
      'ensure' => 'file',
      'source' => '/dev/null/puppet.conf',
    }) }

    it { is_expected.to contain_file('/etc/puppetlabs/puppet/ssl').with({
      'ensure'  => 'directory',
      'source'  => '/dev/null/ssl',
      'backup'  => 'false',
      'recurse' => 'true',
    }) }

    ['agent', 'main', 'master'].each do |section|
      ['catalog_format', 'confdir', 'config_version', 'dbadapter', 'dbconnections', 'dblocation',
       'dbmigrate', 'dbname', 'dbpassword', 'dbport', 'dbsocket', 'dbuser', 'disable_warnings',
       'dynamicfacts', 'legacy_query_parameter_serialization', 'libdir', 'manifest', 'manifestdir',
       'masterlog', 'modulepath', 'parser', 'rails_loglevel', 'railslog', 'rundir', 'stringify_facts',
       'templatedir', 'vardir'].each do |setting|
         it { is_expected.to contain_ini_setting("#{section}/#{setting}").with_ensure('absent') }
       end
    end
  end
end
