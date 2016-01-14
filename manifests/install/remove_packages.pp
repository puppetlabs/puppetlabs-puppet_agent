# == Class puppet_agent::install::remove_packages
#
# This class is used in puppet_agent::install by platforms lacking a package
# manager, where we are required to manually remove the old pe-* packages prior
# to installing puppet-agent.
#
class puppet_agent::install::remove_packages {
  assert_private()

  if versioncmp("${::clientversion}", '4.0.0') < 0 {

    if $::operatingsystem == 'Darwin' {

      contain '::puppet_agent::install::remove_packages_osx'

    } else {

      $package_options = $::operatingsystem ? {
        'SLES'  => {
          uninstall_options => '--nodeps',
          provider          => 'rpm',
        },
        'AIX'  => {
          uninstall_options => '--nodeps',
          provider          => 'rpm',
        },
        'Solaris' => {
          adminfile => '/opt/puppetlabs/packages/solaris-noask',
        },
        default => {
        }
      }

      $packages = $::operatingsystem ? {
        'Solaris' => [
          'PUPpuppet',
          'PUPaugeas',
          'PUPdeep-merge',
          'PUPfacter',
          'PUPhiera',
          'PUPlibyaml',
          'PUPmcollective',
          'PUPopenssl',
          'PUPpuppet-enterprise-release',
          'PUPruby',
          'PUPruby-augeas',
          'PUPruby-rgen',
          'PUPruby-shadow',
          'PUPstomp',
        ],
        default => [
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
        ]
      }

      # We only need to remove these packages if we are transitioning from PE
      # versions that are pre AIO.
      $packages.each |$old_package| {
        package { $old_package:
          ensure => absent,
          *      => $package_options,
        }
      }
    }
  }
}
