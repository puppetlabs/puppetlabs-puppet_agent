require 'beaker-puppet'
require_relative '../helpers'

install_options = {}

if ENV['MASTER_PACKAGE_VERSION']
  install_options[:puppet_agent_version] = ENV['MASTER_PACKAGE_VERSION'].strip
  install_options[:puppet_collection] = puppet_collection_for(:puppet_agent, install_options[:puppet_agent_version])
  description = "at version #{install_options[:puppet_agent_version]}"
elsif ENV['MASTER_COLLECTION']
  install_options[:puppet_collection] = ENV['MASTER_COLLECTION'].downcase.strip
  description = "from collection '#{install_options[:puppet_collection]}'"
else
  description = 'at default version'
end

# Install a puppet-agent package on the master:
test_name "Pre-Suite: Install puppet-agent #{description} on the master" do
  install_puppet_agent_on(master, install_options)

  agent_version = puppet_agent_version_on(master)
  fail_test('Failed to install puppet-agent') unless agent_version

  logger.notify("Installed puppet-agent #{agent_version} on master")
end

# Install a compatible puppetserver:
test_name 'Pre-Suite: Install, configure, and start a compatible puppetserver on the master' do
  server_version = nil

  step 'Install puppetserver' do
    # puppetserver is distributed in "release streams" instead of collections.
    if install_options[:puppet_collection] =~ /^pc1$/i
      # There is no release stream that's equivalent to the PC1 (puppet-agent
      # 1.y.z/puppet 4) collection; This version is fine.
      opts = { version: '2.8.1' }
    else
      # puppet collections _do_ match with server release streams from puppet 5 onward.
      opts = { release_stream: install_options[:puppet_collection] }
    end

    install_puppetserver_on(master, opts)

    server_version = puppetserver_version_on(master)
    fail_test('Failed to install puppetserver') unless server_version
  end

  step 'Configure puppetserver' do
    server_version = puppetserver_version_on(master)
    master_fqdn = on(master, 'facter fqdn').stdout.strip
    master_hostname = on(master, 'hostname').stdout.strip

    puppet_conf = { 'main' => {
      'dns_alt_names' => "puppet,#{master_hostname},#{master_fqdn}",
      'server'        => master_fqdn,
      'verbose'       => true,
    }}

    lay_down_new_puppet_conf(master, puppet_conf, create_tmpdir_on(master))

    unless version_is_less(server_version, '6.0.0')
      tk_config = { 'certificate-authority' => { 'allow-subject-alt-names' => true }}
      path = '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf'
      modify_tk_config(master, path, tk_config)
    end
  end

  step 'Stop the firewall, clear SSL, set up the CA, if needed' do
    stop_firewall_with_puppet_on(master)
    ssldir = puppet_config(master, 'ssldir').strip
    on(master, "rm -rf '#{ssldir}'/*") # Preserve the directory itself, to keep permissions
    # DO NOT RUN 'puppetserver ca setup': this will create the new intermediate certs that
    # will not work when installing the old version of agents.
  end


  step 'Start puppetserver' do
    on(master, puppet('resource', 'service', master['puppetservice'], 'ensure=running', 'enable=true'))
  end
end
