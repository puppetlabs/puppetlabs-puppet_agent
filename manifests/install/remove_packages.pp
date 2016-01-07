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

      if $::operatingsystem == 'SLES' {
        $package_options = {
          uninstall_options => '--nodeps',
          provider          => 'rpm',
        }
      } elsif $::operatingsystem == 'AIX' {
        $package_options = {
          uninstall_options => '--nodeps',
          provider          => 'rpm',
        }
      } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '10' {
        $package_options = {
          adminfile => '/opt/puppetlabs/packages/solaris-noask',
        }
      } else {
        $package_options = {}
      }

      if $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '10' {
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
