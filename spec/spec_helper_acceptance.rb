require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['BEAKER_provision'] == 'no'
  # Work-around for BKR-262
  @logger = logger

  hosts.each do |host|
    # Install Puppet
    if ENV['SHA']
      install_puppetlabs_release_repo(host)
      install_puppetlabs_dev_repo(host, 'puppet', ENV['SHA'])

      #install_packages_from_local_dev_repo(host, 'puppet')
      if host['platform'] =~ /debian|ubuntu|cumulus/
        on host, 'apt-get install -y puppet'
      elsif host['platform'] =~ /fedora|el|centos/
        on host, 'yum install -y puppet'
      else
        raise "No repository installation step for #{host['platform']} yet..."
      end
    elsif host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

configure_puppet(:main => {:stringify_facts => false, :parser => 'future'})

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'agent_upgrade')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
