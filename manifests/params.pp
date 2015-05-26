# == Class agent_upgrade::params
#
# This class is meant to be called from agent_upgrade.
# It sets variables according to platform.
#
class agent_upgrade::params {
  case $::osfamily {
    # TODO: Add Debian, Windows
    'RedHat', 'Amazon': {
      $package_name = 'puppet-agent'
      $service_names = ['puppet', 'mcollective']

      $confdir = '/etc/puppetlabs/puppet'
      $mcodir = '/etc/puppetlabs/mcollective'

      # Can't be detected by puppet, so hard-code it here
      $oldmcodir = '/etc/mcollective'

      # A list of dirs that need to be created. Mainly done this way because
      # Windows requires more directories to exist for confdir.
      $puppetdirs = ['/etc/puppetlabs', $confdir]
      $mcodirs = [$mcodir]
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $ssldir  = "$confdir/ssl"
  $config = "$confdir/puppet.conf"
  $mcoserver = "$mcodir/server.cfg"
  $mcoclient = "$mcodir/client.cfg"
  $oldmcoserver = "$oldmcodir/server.cfg"
  $oldmcoclient = "$oldmcodir/client.cfg"
}
