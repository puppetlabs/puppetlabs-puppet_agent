# == Class puppet_agent::install
#
# This class is called from puppet_agent for install.
#
# === Parameters
#
# [package_file_name]
#   The puppet-agent package file name.
#   (see puppet_agent::prepare::package_file_name)
# [version]
#   The puppet-agent version to install.
#
class puppet_agent::install(
  $package_file_name = undef,
  $package_version   = 'present',
  $install_dir       = undef,
) {
  assert_private()

  $old_packages = (versioncmp("${::clientversion}", '4.0.0') < 0)

  if ($::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '10') or
        $::operatingsystem == 'AIX' {
    contain puppet_agent::install::remove_packages

    exec { 'replace puppet.conf removed by package removal':
      path      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command   => "cp ${puppet_agent::params::confdir}/puppet.conf.rpmsave ${puppet_agent::params::config}",
      creates   => $puppet_agent::params::config,
      require   => Class['puppet_agent::install::remove_packages'],
      before    => Package[$puppet_agent::package_name],
      logoutput => 'on_failure',
    }

    $_package_options = {
      provider        => 'rpm',
      source          => "/opt/puppetlabs/packages/${package_file_name}",
    }
  } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '10' {
    contain puppet_agent::install::remove_packages

    $_unzipped_package_name = regsubst($package_file_name, '\.gz$', '')
    $_package_options = {
      adminfile       => '/opt/puppetlabs/packages/solaris-noask',
      source          => "/opt/puppetlabs/packages/${_unzipped_package_name}",
      require         => Class['puppet_agent::install::remove_packages'],
      install_options => '-G',
    }
  } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '11' and $old_packages {
    # Updating from PE 3.x requires removing all the old packages before installing the puppet-agent package.
    # After puppet-agent is installed, we can use 'pkg update' for future upgrades.
    contain puppet_agent::install::remove_packages

    exec { 'puppet_agent restore /etc/puppetlabs':
      command => 'cp -r /tmp/puppet_agent/puppetlabs /etc',
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      require => Class['puppet_agent::install::remove_packages'],
    }

    exec { 'puppet_agent post-install restore /etc/puppetlabs':
      command     => 'cp -r /tmp/puppet_agent/puppetlabs /etc',
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      refreshonly => true,
    }

    $_package_options = {
      require => Exec['puppet_agent restore /etc/puppetlabs'],
      notify  => Exec['puppet_agent post-install restore /etc/puppetlabs'],
    }
  } elsif $::operatingsystem == 'Darwin' and $::macosx_productversion_major =~ /10\.[9,10,11]/ {
    contain puppet_agent::install::remove_packages

    $_package_options = {
      source    => "/opt/puppetlabs/packages/${package_file_name}",
      require   => Class['puppet_agent::install::remove_packages'],
    }
  } else {
    $_package_options = {}
  }

  if $::osfamily == 'windows' {
    # Prevent re-running the batch install
    if $old_packages or $puppet_agent::aio_upgrade_required {
      if $::puppet_agent::is_pe == true and empty($::puppet_agent::source) {
        $local_package_file_path = windows_native_path("${::puppet_agent::params::local_packages_dir}/${package_file_name}")
        class { 'puppet_agent::windows::install':
          package_file_name => $package_file_name,
          source            => $local_package_file_path,
          install_dir       => $install_dir,
          require           => File[$local_package_file_path],
        }
      } else {
        class { 'puppet_agent::windows::install':
          package_file_name => $package_file_name,
          source            => $::puppet_agent::source,
          install_dir       => $install_dir,
        }
      }
    }
  } elsif ($::osfamily == 'Solaris' and ($::operatingsystemmajrelease == '10' or $old_packages)) or
      $::osfamily == 'Darwin' or $::osfamily == 'AIX' or
      ($::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '10') {
    # Solaris 10/OSX/AIX/SLES 10 package provider does not provide 'versionable'
    # Package is removed above, then re-added as the new version here.
    package { $::puppet_agent::package_name:
      ensure => 'present',
      *      => $_package_options,
    }
  } elsif ($::osfamily == 'RedHat') and ($package_version != 'present') {
    # Workaround PUP-5802/PUP-5025
    if ($::operatingsystem == 'Fedora') {
      $pkg_os_suffix = 'fedoraf'
    } else {
      $pkg_os_suffix = 'el'
    }
    package { $::puppet_agent::package_name:
      ensure => "${package_version}-1.${pkg_os_suffix}${::operatingsystemmajrelease}",
      *      => $_package_options,
    }
  } elsif ($::osfamily == 'Debian') and ($package_version != 'present') {
    # Workaround PUP-5802/PUP-5025
    package { $::puppet_agent::package_name:
      ensure => "${package_version}-1${::lsbdistcodename}",
      *      => $_package_options,
    }
  } else {
    package { $::puppet_agent::package_name:
      ensure => $package_version,
      *      => $_package_options,
    }
  }
}
