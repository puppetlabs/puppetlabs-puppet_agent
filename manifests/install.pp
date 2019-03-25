# == Class puppet_agent::install
#
# This class is called from puppet_agent for install.
#
# === Parameters
#
# [version]
#   The puppet-agent version to install.
#
class puppet_agent::install(
  $package_version   = 'present',
  $install_dir       = undef,
  $install_options   = [],
) {
  assert_private()

  # Solaris, MacOS, Windows platforms will require more than just a package
  # resource to install correctly. These will call to other classes that
  # define how the installations work.
  if $::operatingsystem == 'Solaris' {
    class { 'puppet_agent::install::solaris':
      package_version => $package_version,
      install_options => $install_options,
    }
    contain '::puppet_agent::install::solaris'
  } elsif $::operatingsystem == 'Darwin' {
    # Prevent re-running the script install
    if $puppet_agent::aio_upgrade_required {
      class { 'puppet_agent::install::darwin':
        package_version => $package_version,
        install_options => $install_options,
      }
      contain '::puppet_agent::install::darwin'
    }
  } elsif $::osfamily == 'windows' {
    # Prevent re-running the batch install
    if $puppet_agent::aio_upgrade_required {
      class { 'puppet_agent::install::windows':
        install_dir     => $install_dir,
        install_options => $install_options,
      }
      contain '::puppet_agent::install::windows'
    }
  } else {
    if $::operatingsystem == 'AIX' {
      # AIX installations always use RPM directly since no there isn't any default package manager for rpms
      $_package_version = $package_version
      $_install_options = concat(['--ignoreos'],$install_options)
      $_provider = 'rpm'
      $_source = "${::puppet_agent::params::local_packages_dir}/${::puppet_agent::prepare::package::package_file_name}"
    } elsif $::osfamily == 'Debian' {
      $_install_options = $install_options
      if $::puppet_agent::absolute_source {
        # absolute_source means we use dpkg on debian based platforms
        $_package_version = 'present'
        $_provider = 'dpkg'
        # The source package should have been downloaded by puppet_agent::prepare::package to the local_packages_dir
        $_source = "${::puppet_agent::params::local_packages_dir}/${::puppet_agent::prepare::package::package_file_name}"
      } else {
        # any other type of source means we use apt with no 'source' defined in the package resource below
        if $package_version == 'present' {
          $_package_version = $package_version
        } else {
          $_package_version = "${package_version}-1${::lsbdistcodename}"
        }
        $_provider = 'apt'
        $_source = undef
      }
    } else { # RPM platforms: EL and SUSE
      $_install_options = $install_options
      if $::puppet_agent::absolute_source {
        # absolute_source means we use rpm on EL/suse based platforms
        $_package_version = 'present'
        $_provider = 'rpm'
        # The source package should have been downloaded by puppet_agent::prepare::package to the local_packages_dir
        $_source = "${::puppet_agent::params::local_packages_dir}/${::puppet_agent::prepare::package::package_file_name}"
      } else {
        # any other type of source means we use a package manager (yum or zypper) with no 'source' parameter in the
        # package resource below
        $_package_version = $package_version
        if $::osfamily == 'suse' {
          $_provider = 'zypper'
        } else {
          $_provider = 'yum'
        }
        $_source = undef
      }
    }
    package { $::puppet_agent::package_name:
      ensure          => $_package_version,
      install_options => $_install_options,
      provider        => $_provider,
      source          => $_source,
    }
  }
}
