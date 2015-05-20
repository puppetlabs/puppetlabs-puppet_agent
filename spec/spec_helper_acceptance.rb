require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

def stop_firewall_on(host)
  case host['platform']
  when /debian/
    on host, 'iptables -F'
  when /fedora|el-7/
    on host, puppet('resource', 'service', 'firewalld', 'ensure=stopped')
  when /el|centos/
    on host, puppet('resource', 'service', 'iptables', 'ensure=stopped')
  when /ubuntu/
    on host, puppet('resource', 'service', 'ufw', 'ensure=stopped')
  else
    logger.notify("Not sure how to clear firewall on #{host['platform']}")
  end
end

# Project root
PROJ_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

unless ENV['BEAKER_provision'] == 'no'
  # Work-around for BKR-262
  @logger = logger

  # Setup repositories if using a specific SHA
  if ENV['SHA']
    hosts.each do |host|
      install_puppetlabs_release_repo(host)
      install_puppetlabs_dev_repo(host, 'puppet', ENV['SHA'])
    end

    if master
      install_package master, 'puppet-server'
      master['use-service'] = true
    end
  end
end

def parser_opts
  # Configuration only needed on 3.x master
  {
    :main => {:stringify_facts => false, :parser => 'future'},
    :agent => {:ssldir => '$vardir/ssl'},
  }
end

def setup_puppet(agent_run = false)

  agents.each do |agent|
    # Install Puppet
    if ENV['SHA']
      install_package agent, 'puppet'
    elsif agent.is_pe?
      install_pe
    else
      install_puppet
    end

    configure_puppet_on(agent, parser_opts)
  end

  if master and agent_run
    # Initialize SSL
    hostname = on(master, 'facter hostname').stdout.strip
    fqdn = on(master, 'facter fqdn').stdout.strip

    if master.use_service_scripts?
      step "Ensure puppet is stopped"
      # Passenger, in particular, must be shutdown for the cert setup steps to work,
      # but any running puppet master will interfere with webrick starting up and
      # potentially ignore the puppet.conf changes.
      on(master, puppet('resource', 'service', master['puppetservice'], "ensure=stopped"))
    end

    step "Clear SSL on all hosts"
    hosts.each do |host|
      stop_firewall_on host
      ssldir = on(host, puppet('agent --configprint ssldir')).stdout.chomp
      on(host, "rm -rf '#{ssldir}'")
    end

    step "Master: Start Puppet Master" do
      master_opts = {
        :main => {
          :dns_alt_names => "puppet,#{hostname},#{fqdn}",
        },
        :__service_args__ => {
          # apache2 service scripts can't restart if we've removed the ssl dir
          :bypass_service_script => true,
        },
      }
      with_puppet_running_on(master, master_opts, master.tmpdir('puppet')) do
        step "Agents: Run agent --test first time to gen CSR"
        on agents, puppet("agent --test --server #{master}"), :acceptable_exit_codes => [1]

        step "Master: sign all certs"
        on master, puppet("cert --sign --all"), :acceptable_exit_codes => [0,24]

        step "Agents: Run agent --test second time to obtain signed cert"
        on agents, puppet("agent --test --server #{master}"), :acceptable_exit_codes => [0,2]
      end
    end

    if master.graceful_restarts?
      on(master, puppet('resource', 'service', master['puppetservice'], "ensure=running"))
    end
  end

  # Install module and dependencies
  puppet_module_install(:source => PROJ_ROOT, :module_name => 'agent_upgrade')
  on hosts, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
  on hosts, puppet('module', 'install', 'puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
end

def teardown_puppet
  # Note pc1_repo is specific to the module's manifests. This is knowledge we need to clean
  # the machine after each run.
  pp = <<-EOS
package { 'puppet-agent': ensure => absent }
package { 'puppet': ensure => absent }
file { ['/etc/puppet', '/etc/puppetlabs', '/etc/mcollective']: ensure => absent, force => true, backup => false }
yumrepo { 'pc1_repo': ensure => absent }
  EOS
  on agents, "/opt/puppetlabs/bin/puppet apply -e \"#{pp}\""
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
