require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'erb'

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

# Helper for setting the activemq host in erb templates.
def activemq_host
  'activemq'
end

def install_modules_on(host)
  puppet_module_install_on(host, :source => PROJ_ROOT, :module_name => 'puppet_agent')
  on host, puppet('module', 'install', 'puppetlabs-stdlib'), {:acceptable_exit_codes => [0, 1]}
  on host, puppet('module', 'install', 'puppetlabs-inifile'), {:acceptable_exit_codes => [0, 1]}
  on host, puppet('module', 'install', 'puppetlabs-apt'), {:acceptable_exit_codes => [0, 1]}
  on host, puppet('module', 'install', 'puppetlabs-transition'), {:acceptable_exit_codes => [0, 1]}
end

unless ENV['BEAKER_provision'] == 'no'
  if default['platform'] =~ /windows/i
    if default['platform'] =~ /2003/
      default['install_32'] = true #Ensure we only attempt to install 32 bit on server 2003
    end
    install_pe
  else
    # Install puppet-server on master
    options['is_puppetserver'] = true
    master['puppetservice'] = 'puppetserver'
    master['puppetserver-confdir'] = '/etc/puppetlabs/puppetserver/conf.d'
    master['type'] = 'aio'
    install_puppet_agent_on master, {}
    install_package master, 'puppetserver'
    master['use-service'] = true

    install_modules_on master

    # Install activemq on master
    install_puppetlabs_release_repo master
    install_package master, 'activemq'

    ['truststore', 'keystore'].each do |ext|
      scp_to master, "#{TEST_FILES}/activemq.#{ext}", "/etc/activemq/activemq.#{ext}"
    end

    erb = ERB.new(File.read("#{TEST_FILES}/activemq.xml.erb"))
    create_remote_file master, '/etc/activemq/activemq.xml', erb.result(binding)

    stop_firewall_on master
    on master, puppet('resource', 'service', 'activemq', 'ensure=running')

    # sleep to give activemq time to start
    sleep 10
  end
end

unless ENV['MODULE_provision'] == 'no'
  if default['platform'] =~ /windows/i
    target = (on default, puppet('config print modulepath')).stdout.split(';')[0]
    {'stdlib' => '4.6.0', 'inifile' => '1.3.0', 'apt' => '2.0.1', 'transition' => '0.1.0'}.each do |repo, version|
      on default, "rm -rf \"#{target}/#{repo}\";git clone --branch #{version} --depth 1 https://github.com/puppetlabs/puppetlabs-#{repo} \"#{target}/#{repo}\""
    end
    # default['distmoduledir'] = '`cygpath -smF 35`/PuppetLabs/puppet/etc/modules' should be set
    install_dev_puppet_module_on(default, {:proj_root => PROJ_ROOT, :module_name => 'puppet_agent'})
  end
end

def parser_opts
  # Configuration only needed on 3.x master
  {
    :main => {:stringify_facts => false, :parser => 'future', :color => 'ansi'},
    :agent => {:stringify_facts => false, :cfacter => true, :ssldir => '$vardir/ssl'},
  }
end

def server_opts
  {
    :master => {:autosign => true, :dns_alt_names => master},
  }
end

def setup_puppet_on(host, opts = {})
  opts = {:agent => false, :mcollective => false}.merge(opts)

  puts "Setup foss puppet on #{host}"
  configure_defaults_on host, 'foss'
  install_puppet_on host, :version => ENV['PUPPET_CLIENT_VERSION'] || '3.8.6'

  configure_puppet_on(host, parser_opts)

  if opts[:mcollective]
    install_package host, 'mcollective'
    install_package host, 'mcollective-client'
    stop_firewall_on host

    ['ca_crt.pem', 'server.crt', 'server.key', 'client.crt', 'client.key'].each do |file|
      scp_to host, "#{TEST_FILES}/#{file}", "/etc/mcollective/#{file}"
    end

    ['client.cfg', 'server.cfg'].each do |file|
      erb = ERB.new(File.read("#{TEST_FILES}/#{file}.erb"))
      create_remote_file host, "/etc/mcollective/#{file}", erb.result(binding)
    end

    on host, 'mkdir /etc/mcollective/ssl-clients'
    scp_to host, "#{TEST_FILES}/client.crt", '/etc/mcollective/ssl-clients/client.pem'
    on host, 'mkdir -p /usr/libexec/mcollective/plugins'

    # Ensure the domain used to find activemq_host resolves to an ip address.
    # The domain is set based on the certificate used for testing.
    on host, puppet('resource', 'host', activemq_host, "ip=#{master['ip'] || master.ip}")
    on host, puppet('resource', 'service', 'mcollective', 'ensure=stopped')
    on host, puppet('resource', 'service', 'mcollective', 'ensure=running')
  end

  if opts[:agent]
    puts "Clear SSL on all hosts and disable firewalls"
    hosts.each do |host|
      stop_firewall_on host
      on(host, "rm -rf '#{host.puppet['ssldir']}'")
    end
  else
    install_modules_on host
  end
end

def configure_agent_on(host, agent_run = false)
  configure_defaults_on host, 'aio'
  install_modules_on host unless agent_run
end

def teardown_puppet_on(host)
  puts "Purge puppet from #{host}"
  # Note pc_repo is specific to the module's manifests. This is knowledge we need to clean
  # the machine after each run.
  case host['platform']
    when /debian|ubuntu/
      on host, '/opt/puppetlabs/bin/puppet module install puppetlabs-apt', {:acceptable_exit_codes => [0, 1]}
      clean_repo = "include apt\napt::source { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
    when /fedora|el|centos/
      clean_repo = "yumrepo { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
    else
      logger.notify("Not sure how to remove repos on #{host['platform']}")
      clean_repo = ''
  end

  pp = <<-EOS
#{clean_repo}
file { ['/etc/puppet', '/etc/puppetlabs', '/etc/mcollective']: ensure => absent, force => true, backup => false }
package { ['puppet-agent', 'puppet', 'mcollective', 'mcollective-client']: ensure => purged }
  EOS
  on host, puppet('apply', '-e', "\"#{pp}\"", '--no-report')
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
