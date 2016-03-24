# == Class puppet_agent::install::remove_packages
#
# This class is used in puppet_agent::install by platforms lacking a package
# manager, where we are required to manually remove the old pe-* packages prior
# to installing puppet-agent.
#
class puppet_agent::install::remove_packages(
  $package_version = undef
  ) {
  assert_private()

  if $::operatingsystem == 'Darwin' {
    contain '::puppet_agent::install::remove_packages_osx'
  } else {
    $package_options = $::operatingsystem ? {
      'SLES'  => {
        ensure            => 'absent',
        uninstall_options => '--nodeps',
        provider          => 'rpm',
      },
      'AIX'  => {
        ensure            => 'absent',
        uninstall_options => '--nodeps',
        provider          => 'rpm',
      },
      'Solaris' => {
        ensure            => 'absent',
        adminfile => '/opt/puppetlabs/packages/solaris-noask',
      },
      default => {
        ensure            => 'absent',
      }
    }

    if versioncmp("${::clientversion}", '4.0.0') < 0 {
      # We only need to remove these packages if we are transitioning from PE
      # versions that are pre AIO.
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
    } elsif versioncmp("${::aio_agent_version}", "${::puppet_agent::package_version}") < 0 {
      $packages = [ 'puppet-agent' ]
    } else {
      $packages = []
    }
    $packages.each |$old_package| {
      if (versioncmp("${::clientversion}", '4.0.0') < 0) {
        package { $old_package:
          * => $package_options,
        }
      } else {
        # We must use transition here because we would have a duplicate package
        # declaration if we used a Package.
        notify { "using puppetlabs-transition to remove ${old_package}: ${::operatingsystem} does not support versionable": }
        transition { "remove ${old_package}":
          resource   => Package[$old_package],
          attributes => $package_options,
          prior_to   => Notify["using puppetlabs-transition to remove ${old_package}: ${::operatingsystem} does not support versionable"],
        }
      }
    }
  }
}
