# == Class puppet_agent::params
#
# This class is meant to be called from puppet_agent.
# It sets variables according to platform.
#
class puppet_agent::params {
  case $::osfamily {
    # TODO: Add Debian, Windows
    'RedHat', 'Amazon': {
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
