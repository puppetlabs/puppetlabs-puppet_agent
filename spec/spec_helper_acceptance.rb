require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['BEAKER_provision'] == 'no'
  # Work-around for BKR-262
  @logger = logger

  # Setup repositories if using a specific SHA
  hosts.each do |host|
    if ENV['SHA']
      install_puppetlabs_release_repo(host)
      install_puppetlabs_dev_repo(host, 'puppet', ENV['SHA'])
    end
  end
end

def setup_puppet
  hosts.each do |host|
    # Install Puppet
    if ENV['SHA']
      if host['platform'] =~ /debian|ubuntu|cumulus/
        on host, 'apt-get install -y puppet'
      elsif host['platform'] =~ /fedora|el|centos/
        on host, 'yum install -y puppet'
      else
        raise "No package installation step for #{host['platform']} yet..."
      end
    elsif host.is_pe?
      install_pe
    else
      install_puppet
    end
  end

  configure_puppet(:main => {:stringify_facts => false, :parser => 'future'})

  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Install module and dependencies
  puppet_module_install(:source => proj_root, :module_name => 'agent_upgrade')
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
  on hosts, "/opt/puppetlabs/bin/puppet apply -e \"#{pp}\""
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
