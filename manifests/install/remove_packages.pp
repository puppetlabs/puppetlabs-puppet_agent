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
        adminfile         => '/opt/puppetlabs/packages/solaris-noask',
      },
      default => {
        ensure            => 'absent',
      }
    }

    if versioncmp("${::clientversion}", '4.0.0') < 0 {
      # We only need to remove these packages if we are transitioning from PE
      # versions that are pre AIO.
      if $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '10' {
        # Tidy up pe-puppet and pe-mcollective services that would be left running
        # after package removal.
        service { 'pe-mcollective':
          ensure  => stopped,
        }
        service { 'pe-puppet':
          ensure => stopped,
        }

        $packages = [
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
        ]
      } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '11' {
        $packages = [
          'pe-mcollective',
          'pe-mcollective-common',
          'pe-virt-what',
          'pe-libldap',
          'pe-deep-merge',
          'pe-ruby-ldap',
          'pe-ruby-augeas',
          'pe-ruby-shadow',
          'pe-puppet',
          'pe-facter',
        ]
        package { 'pe-augeas':
          ensure  => absent,
          require => Package['pe-ruby-augeas'],
        }
        package { 'pe-stomp':
          ensure  => absent,
          require => Package['pe-mcollective'],
        }
        package { ['pe-hiera', 'pe-ruby-rgen']:
          ensure  => absent,
          require => Package['pe-puppet'],
        }
        package { 'pe-ruby':
          ensure  => absent,
          require => Package[
            'pe-hiera',
            'pe-deep-merge',
            'pe-ruby-rgen',
            'pe-stomp',
            'pe-ruby-shadow',
            'pe-puppet',
            'pe-mcollective',
            'pe-facter',
            'pe-facter',
            'pe-ruby-augeas'
          ]
        }
        package { ['pe-openssl', 'pe-libyaml']:
          ensure  => absent,
          require => Package['pe-ruby'],
        }
        package { 'pe-puppet-enterprise-release':
          ensure  => absent,
          require => Package[
            'pe-hiera',
            'pe-stomp',
            'pe-deep-merge',
            'pe-libyaml',
            'pe-ruby',
            'pe-ruby-shadow',
            'pe-augeas',
            'pe-puppet',
            'pe-ruby-rgen',
            'pe-facter',
            'pe-mcollective',
            'pe-ruby-augeas'
          ],
        }
      } else {
        $packages = [
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
    } elsif $puppet_agent::aio_upgrade_required {
      $packages = [ 'puppet-agent' ]
    } else {
      $packages = []
    }
    $packages.each |$old_package| {
      if (versioncmp("${::clientversion}", '4.0.0') < 0) {
        package { $old_package:
          * => $package_options,
        }
      } elsif $puppet_agent::aio_upgrade_required {
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
