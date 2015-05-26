require 'spec_helper'

base_facts = {
  :osfamily               => 'RedHat',
  :puppet_ssldir          => '/dev/null/ssl',
  :puppet_config          => '/dev/null/puppet.conf',
  :mcollective_configured => false,
}

describe 'agent_upgrade::prepare' do
  context 'on RedHat' do
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
      ['allow_variables_with_dashes',
       'async_storeconfigs',
       'binder',
       'catalog_format',
       'certdnsnames',
       'certificate_expire_warning',
       'couchdb_url',
       'dbadapter',
       'dbconnections',
       'dblocation',
       'dbmigrate',
       'dbname',
       'dbpassword',
       'dbport',
       'dbserver',
       'dbsocket',
       'dbuser',
       'dynamicfacts',
       'http_compression',
       'httplog',
       'ignoreimport',
       'immutable_node_data',
       'inventory_port',
       'inventory_server',
       'inventory_terminus',
       'legacy_query_parameter_serialization',
       'listen',
       'localconfig',
       'manifestdir',
       'masterlog',
       'parser',
       'preview_outputdir',
       'puppetport',
       'queue_source',
       'queue_type',
       'rails_loglevel',
       'railslog',
       'report_serialization_format',
       'reportfrom',
       'rrddir',
       'rrdinterval',
       'sendmail',
       'smtphelo',
       'smtpport',
       'smtpserver',
       'ssldir',
       'stringify_facts',
       'tagmap',
       'templatedir',
       'thin_storeconfigs',
       'trusted_node_data',
       'zlib',
       'config_version',
       'manifest',
       'modulepath',
       'disable_warnings',
       'vardir',
       'rundir',
       'libdir',
       'confdir'].each do |setting|
         it { is_expected.to contain_ini_setting("#{section}/#{setting}").with_ensure('absent') }
       end
    end

    it { is_expected.to contain_class('agent_upgrade::osfamily::redhat') }
  end
end
