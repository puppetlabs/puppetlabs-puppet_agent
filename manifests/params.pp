# == Class puppet_agent::params
#
# This class is meant to be called from puppet_agent.
# It sets variables according to platform.
#
class puppet_agent::params {

  # If this is PE, by default the packages are kept on the master,
  # However if they are in a large environment with compile masters,
  # they may have the packages on a different server.
  if $::is_pe {
    # The repo structure on the PE master is the following:
    # https://server:8140/packages/pe_version/os-os_version-os_arch
    # https://server:8140/packages/3.8.0/el-7-x86_64
    $_source = "https://${::servername}:8140/packages"
  }
  else {
    $_source = undef
  }

  case $::osfamily {
    'RedHat', 'Amazon', 'Debian', 'Suse': {
      $package_name = 'puppet-agent'
      $service_names = ['puppet', 'mcollective']

      $confdir = '/etc/puppetlabs/puppet'
      $mco_dir = '/etc/puppetlabs/mcollective'

      $mco_install = '/opt/puppetlabs/mcollective'
      $logdir = '/var/log/puppetlabs'

      # A list of dirs that need to be created. Mainly done this way because
      # Windows requires more directories to exist for confdir.
      $puppetdirs = ['/etc/puppetlabs', $confdir]
      $mcodirs = [$mco_dir]

      $path_separator = ':'
    }
    'windows' : {
      $confdir = $puppet_confdir
      $mco_dir = $mco_confdir

      $mcodirs = [$mco_dir] # Directories should already exists as they have not changed
      $puppetdirs = [regsubst($confdir,'\/etc\/','/code/')]
      $path_separator = ';'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $ssldir = "$confdir/ssl"
  $config = "$confdir/puppet.conf"

  $mco_server  = "$mco_dir/server.cfg"
  $mco_client  = "$mco_dir/client.cfg"
  $mco_libdir  = "$mco_install/plugins"
  $mco_plugins = "$mco_dir/facts.yaml"
  $mco_log     = "$logdir/mcollective.log"
}
