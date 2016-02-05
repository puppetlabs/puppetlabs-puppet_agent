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

    if $::osfamily == 'windows' {
      $tag = $::puppet_agent::arch ? {
        'x64' => 'windows-x86_64',
      }
      $source = "puppet:///pe_packages/${pe_server_version}/${tag}/${package_file_name}"
    } else {
      $source = "puppet:///pe_packages/${pe_server_version}/${::platform_tag}/${package_file_name}"
    }

    # Manage /opt/puppetlabs for platforms
    if !defined(File[$::puppet_agent::params::local_puppet_dir]) {
      file { $::puppet_agent::params::local_puppet_dir:
        ensure => directory,
      }
    }

    file { $::puppet_agent::params::local_packages_dir:
      ensure => directory,
    }
    file { "${::puppet_agent::params::local_packages_dir}/${package_file_name}":
      ensure  => present,
      owner   => $::puppet_agent::params::user,
      group   => $::puppet_agent::params::group,
      mode    => '0644',
      source  => $source,
      require => File[$::puppet_agent::params::local_packages_dir],
    }
  }
}
