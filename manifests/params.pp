# == Class puppet_agent::params
#
# This class is meant to be called from puppet_agent
# It sets variables according to platform.
#
class puppet_agent::params {

  # The `is_pe` fact currently works by echoing out the puppet version
  # and greping for "puppet enterprise". With Puppet 4 and PE 2015.2, there
  # is no longer a "PE Puppet", and so that fact will no longer work.
  # Instead check both the `is_pe` fact as well as if a PE provided
  # function is available
  $_is_pe = ($::is_pe or is_function_available('pe_compiling_server_version'))

  # In Puppet Enterprise, agent packages are provided by the master
  # with a default prefix of `/packages`.
  if $::osfamily != 'windows' {
    $_source = $_is_pe ? {
      true    => "https://${::servername}:8140/packages",
      default => undef,
    }
  }

  case $::osfamily {
    'RedHat', 'Amazon', 'Debian', 'Suse', 'Solaris', 'Darwin', 'AIX': {
      $package_name = 'puppet-agent'
      $service_names = ['puppet', 'mcollective']

      $local_puppet_dir = '/opt/puppetlabs'
      $local_packages_dir = "${local_puppet_dir}/packages"

      $confdir = '/etc/puppetlabs/puppet'
      $mco_dir = '/etc/puppetlabs/mcollective'

      $mco_install = "${local_puppet_dir}/mcollective"
      $logdir = '/var/log/puppetlabs'

      # A list of dirs that need to be created. Mainly done this way because
      # Windows requires more directories to exist for confdir.
      $puppetdirs = ['/etc/puppetlabs', $confdir]
      $mcodirs = [$mco_dir]

      $path_separator = ':'

      $user  = 0
      $group = 0
    }
    'windows' : {
      $package_name = 'puppet-agent'
      $service_names = ['puppet', 'mcollective']

      $local_puppet_dir = windows_native_path("${::common_appdata}/Puppetlabs")
      $local_packages_dir = windows_native_path("${local_puppet_dir}/packages")

      $confdir = $::puppet_confdir
      $mco_dir = $::mco_confdir

      $mcodirs = [$mco_dir] # Directories should already exists as they have not changed
      $puppetdirs = [regsubst($confdir,'\/etc\/','/code/')]
      $path_separator = ';'

      $user  = 'S-1-5-32-544'
      $group = 'S-1-5-32-544'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # The aio puppet-agent version currently installed on the compiling master
  # (only used in PE)
  $master_agent_version = $_is_pe ? {
    true    => pe_compiling_server_aio_build(),
    default => undef,
  }

  $ssldir = "${confdir}/ssl"
  $config = "${confdir}/puppet.conf"

  $mco_server  = "${mco_dir}/server.cfg"
  $mco_client  = "${mco_dir}/client.cfg"
  $mco_libdir  = "${mco_install}/plugins"
  $mco_plugins = "${mco_dir}/facts.yaml"
  $mco_log     = "${logdir}/mcollective.log"
}
