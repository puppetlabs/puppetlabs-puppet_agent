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
TEST_FILES = File.expand_path(File.join(File.dirname(__FILE__), 'acceptance', 'files'))

unless ENV['BEAKER_provision'] == 'no'
  # Work-around for BKR-262
  @logger = logger

  # Install repos on hosts
  hosts.each do |host|
    install_puppetlabs_release_repo(host)

    if ENV['SHA']
      step "Setup dev repositories"
      install_puppetlabs_dev_repo(host, 'puppet', ENV['SHA'])
    end
  end

  # Install puppet-server on master
  if master
    install_package master, 'puppet-server'
    master['use-service'] = true

    step "Install module and dependencies"
    puppet_module_install_on(master, :source => PROJ_ROOT, :module_name => 'puppet_agent')
    on master, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    on master, puppet('module', 'install', 'puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
  end
end

def parser_opts
  # Configuration only needed on 3.x master
  {
    :main => {:stringify_facts => false, :parser => 'future', :color => 'ansi'},
    :agent => {:stringify_facts => false, :cfacter => true, :ssldir => '$vardir/ssl'},
    :master => {:stringify_facts => false, :cfacter => true},
  }
end

def setup_puppet_on(host, opts = {})
  opts = {:agent => false, :mcollective => false}.merge(opts)

  step "Setup puppet on #{host}"
  install_package host, 'puppet'

  configure_puppet_on(host, parser_opts)

  if opts[:mcollective]
    install_package host, 'mcollective'
    install_package host, 'mcollective-client'
    install_package host, 'activemq'

    ['xml', 'truststore', 'keystore'].each do |ext|
      scp_to host, "#{TEST_FILES}/activemq.#{ext}", "/etc/activemq/activemq.#{ext}"
    end

    on host, puppet('resource', 'service', 'activemq', 'ensure=running')

    # sleep to give activemq time to start
    sleep 10

    ['server.cfg', 'client.cfg', 'ca_crt.pem', 'server.crt', 'server.key', 'client.crt', 'client.key'].each do |file|
      scp_to host, "#{TEST_FILES}/#{file}", "/etc/mcollective/#{file}"
    end

    on host, 'mkdir /etc/mcollective/ssl-clients'
    scp_to host, "#{TEST_FILES}/client.crt", '/etc/mcollective/ssl-clients/client.pem'
    on host, 'mkdir -p /usr/libexec/mcollective/plugins'

    on host, puppet('resource', 'service', 'mcollective', 'ensure=stopped')
    on host, puppet('resource', 'service', 'mcollective', 'ensure=running')
  end

  if master and opts[:agent]
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

    step "Master: Start Puppet Master"
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
      on host, puppet("agent --test --server #{master}"), :acceptable_exit_codes => [1]

      step "Master: sign all certs"
      on master, puppet("cert --sign --all"), :acceptable_exit_codes => [0,24]

      step "Agents: Run agent --test second time to obtain signed cert"
      on host, puppet("agent --test --server #{master}"), :acceptable_exit_codes => [0,2]
    end

    if master.graceful_restarts?
      on(master, puppet('resource', 'service', master['puppetservice'], "ensure=running"))
    end
  else
    step "Install module and dependencies"
    puppet_module_install_on(host, :source => PROJ_ROOT, :module_name => 'puppet_agent')
    on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    on host, puppet('module', 'install', 'puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
  end
end

def teardown_puppet_on(host)
  step "Purge puppet from #{host}"
  # Note pc1_repo is specific to the module's manifests. This is knowledge we need to clean
  # the machine after each run.
  pp = <<-EOS
package { ['puppet-agent', 'puppet', 'mcollective', 'mcollective-client', 'activemq']: ensure => purged }
file { ['/etc/puppet', '/etc/puppetlabs', '/etc/mcollective', '/etc/activemq']: ensure => absent, force => true, backup => false }
yumrepo { 'pc1_repo': ensure => absent }
  EOS
  on host, "/opt/puppetlabs/bin/puppet apply -e \"#{pp}\""
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
