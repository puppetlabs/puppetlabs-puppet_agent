# == Class puppet_agent::prepare::package
#
# The only job this class has is to ensure that the correct puppet-agent
# package is downloaded locally for installation.  This is used on platforms
# without package managers capable of working with a remote https repository.
#
# [package_file_name]
#   The puppet-agent package file to retrieve from the master.
#
class puppet_agent::prepare::package(
  $package_file_name,
) {
  assert_private()

  # Guard this so that we do not perform expensive checksum logic on the master
  # for the large puppet-agent file if we have already upgraded.
  if $puppet_agent::params::master_agent_version != $::aio_agent_version {
    $pe_server_version = pe_build_version()

    $source = "puppet:///pe_packages/${pe_server_version}/${::platform_tag}/${package_file_name}"

    file { ['/opt/puppetlabs', '/opt/puppetlabs/packages']:
      ensure => directory,
    }
    file { "/opt/puppetlabs/packages/${package_file_name}":
      ensure => present,
      owner  => 0,
      group  => 0,
      mode   => '0644',
      source => $source,
    }
  }
}
