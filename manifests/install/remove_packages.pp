# == Class puppet_agent::install::remove_packages
#
# This class is used in puppet_agent::install by platforms lacking a package
# manager, where we are required to manually remove the old pe-* packages prior
# to installing puppet-agent.
#
class puppet_agent::install::remove_packages {
  assert_private()

  if versioncmp("${::clientversion}", '4.0.0') < 0 {
    # We only need to remove these packages if we are transitioning from PE
    # versions that are pre AIO.
    [
      'pe-augeas',
      'pe-mcollective-common',
      'pe-rubygem-deep-merge',
      'pe-mcollective',
      'pe-puppet-enterprise-release',
      'pe-libldap',
      'pe-libyaml',
      'pe-ruby-stomp',
      'pe-ruby-augeas',
      'pe-ruby-shadow',
      'pe-hiera',
      'pe-facter',
      'pe-puppet',
      'pe-openssl',
      'pe-ruby',
      'pe-ruby-rgen',
      'pe-virt-what',
      'pe-ruby-ldap',
    ].each |$old_package| {
      package { $old_package:
        ensure            => absent,
        uninstall_options => '--nodeps',
        provider          => 'rpm',
      }
    }
  }
}
