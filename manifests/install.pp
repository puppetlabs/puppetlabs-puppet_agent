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
  $install_options   = [],
) {
  assert_private()

  $pa_collection = getvar('::puppet_agent::collection')

  if $::operatingsystem == 'AIX' {
    $_install_options = concat(['--ignoreos'],$install_options)

    package { $::puppet_agent::package_name:
      ensure          => $package_version,
      provider        => 'rpm',
      source          => "/opt/puppetlabs/packages/${package_file_name}",
      install_options => $_install_options,
    }
  } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '10' {
    $_unzipped_package_name = regsubst($package_file_name, '\.gz$', '')
    $install_script = 'solaris_install.sh.erb'

    # The following are expected to be available in the solaris_install.sh.erb template:
    $adminfile = '/opt/puppetlabs/packages/solaris-noask'
    $sourcefile = "/opt/puppetlabs/packages/${_unzipped_package_name}"
    $service_names = $puppet_agent::service_names

    # Puppet prior to 5.0 would not use a separate process contract when forking from the Puppet
    # service. That resulted in service-initiated upgrades failing because trying to remove or
    # upgrade the package would stop the service, thereby killing the Puppet run. Use a script
    # to perform the upgrade after Puppet is done running.
    # Puppet 5.0 adds this, but some i18n implementation is loading code fairly late and appears
    # to be messing up the upgrade.

    if $puppet_agent::aio_upgrade_required {
      $_logfile = "${::env_temp_variable}/solaris_install.log"
      notice ("Puppet install log file at ${_logfile}")

      $_installsh = "${::env_temp_variable}/solaris_install.sh"
      file { "${_installsh}":
        ensure  => file,
        mode    => '0755',
        content => template('puppet_agent/do_install.sh.erb')
      }
      -> exec { 'solaris_install script':
        command => "/usr/bin/ctrun -l none ${_installsh} ${::puppet_agent_pid} 2>&1 > ${_logfile} &",
      }
    }
  } elsif $::operatingsystem == 'Darwin' {
    if $puppet_agent::aio_upgrade_required {
      $install_script = 'osx_install.sh.erb'

      $_logfile = "${::env_temp_variable}/osx_install.log"
      notice("Puppet install log file at ${_logfile}")

      $_installsh = "${::env_temp_variable}/osx_install.sh"
      file { "${_installsh}":
        ensure  => file,
        mode    => '0755',
        content => template('puppet_agent/do_install.sh.erb')
      }
      -> exec { 'osx_install script':
        command => "${_installsh} ${::puppet_agent_pid} 2>&1 > ${_logfile} &",
      }
    }
  } elsif $::osfamily == 'windows' {
    # Prevent re-running the batch install
    if $puppet_agent::aio_upgrade_required {
      if $::puppet_agent::is_pe == true and empty($::puppet_agent::source) {
        $local_package_file_path = windows_native_path("${::puppet_agent::params::local_packages_dir}/${package_file_name}")
        class { 'puppet_agent::windows::install':
          package_file_name => $package_file_name,
          source            => $local_package_file_path,
          install_dir       => $install_dir,
          require           => File[$local_package_file_path],
          install_options   => $install_options,
        }
      } else {
        class { 'puppet_agent::windows::install':
          package_file_name => $package_file_name,
          source            => $::puppet_agent::source,
          install_dir       => $install_dir,
          install_options   => $install_options,
        }
      }
    }
  } elsif ($::osfamily == 'Debian') and ($package_version != 'present') {
    package { $::puppet_agent::package_name:
      ensure          => "${package_version}-1${::lsbdistcodename}",
      install_options => $install_options,
    }
  } else {
    package { $::puppet_agent::package_name:
      ensure          => $package_version,
      install_options => $install_options,
    }
  }
}
