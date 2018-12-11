require 'beaker-puppet'
require_relative '../helpers'

opts = agent_install_options

if opts[:puppet_agent_version]
  description = "at version #{opts[:puppet_agent_version]}"
elsif opts[:puppet_collection]
  description = "from collection '#{opts[:puppet_collection]}'"
else
  description = 'at default version'
end

# Install an agent package on the master:
test_name "Pre-Suite: Install puppet-agent #{description} on the master" do
  install_puppet_agent_on(master, opts)

  agent_version = puppet_agent_version_on(master)
  fail_test('Failed to install puppet-agent') unless agent_version

  logger.notify("Installed puppet-agent #{agent_version}")
end

# We'll assume here that the agent package has been installed from a repo
# (since master platforms all use repos) and that we can grab whatever
# puppetserver comes with that repo:
test_name 'Pre-Suite: Install and start a compatible puppetserver on the master' do
  install_package(master, 'puppetserver')
  master_fqdn = on(master, 'facter fqdn').stdout.strip
  master_hostname = on(master, 'hostname').stdout.strip

  configure_puppet_on(master, {
    'main' => { 'server' => master_fqdn },
    'master' => { 'dns_alt_names' => "puppet,#{master_hostname},#{master_fqdn}"}
  })

  server_version = puppetserver_version_on(master)
  fail_test('Failed to install puppetserver') unless server_version

  logger.notify("Installed puppetserver #{server_version}")

  stop_firewall_with_puppet_on(master)
  on(master, puppet('resource', 'service', master['puppetservice'], 'ensure=running', 'enable=true'))
end

# Now install the puppet_agent module itself, and its dependencies
test_name 'Pre-Suite: Install puppet_agent module and dependencies on the master' do
  install_modules_on(master)
end
