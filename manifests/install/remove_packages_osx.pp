# == Class puppet_agent::install::remove_packages_osx
#
# Sadly, special handling is required to clear up puppet_enterprise installation
# on 3.8.
#
class puppet_agent::install::remove_packages_osx {
  assert_private()

  if $::puppet_agent::is_pe {
    if versioncmp("${::clientversion}", '4.0.0') < 0 {
      # shutdown services
      service { 'pe-puppet':
        ensure => stopped,
      }->
      service { 'pe-mcollective':
        ensure => stopped,
      }->

      # remove old users and groups
      user { 'pe-puppet':
        ensure => absent,
      }->
      user { 'pe-mcollective':
        ensure => absent,
      }->

      # remove old /opt/puppet files
      file { '/opt/puppet':
        ensure => absent,
        force  => true,
        backup => false,
      }
      # Can't delete /var/opt/lib/pe-puppet or we get errors because
      # /var/opt/lib/pe-puppet/state is missing when puppet run tries to save
      # report

      # forget packages
      [
        'pe-augeas',
        'pe-ruby-augeas',
        'pe-openssl',
        'pe-ruby',
        'pe-cfpropertylist',
        'pe-facter',
        'pe-puppet',
        'pe-mcollective',
        'pe-hiera',
        'pe-puppet-enterprise-release',
        'pe-stomp',
        'pe-libyaml',
        'pe-ruby-rgen',
        'pe-deep-merge',
        'pe-ruby-shadow',
      ].each |$package| {
        exec { "forget ${package}":
          command => "/usr/sbin/pkgutil --forget com.puppetlabs.${package}",
          require => File['/opt/puppet'],
        }
      }
    }
  }
}
