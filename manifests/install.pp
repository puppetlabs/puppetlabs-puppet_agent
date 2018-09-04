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

  $old_packages = (versioncmp("${::clientversion}", '4.0.0') < 0)
  $pa_collection = getvar('::puppet_agent::collection')

  if ($::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '10') or $::operatingsystem == 'AIX' {
    $_install_options = $::operatingsystem ? {
      'AIX'   => concat(['--ignoreos'],$install_options),
      default => $install_options
    }

    if $old_packages {
      contain puppet_agent::install::remove_packages

      exec { 'replace puppet.conf removed by package removal':
        path      => '/bin:/usr/bin:/sbin:/usr/sbin',
        command   => "cp ${puppet_agent::params::confdir}/puppet.conf.rpmsave ${puppet_agent::params::config}",
        creates   => $puppet_agent::params::config,
        require   => Class['puppet_agent::install::remove_packages'],
        before    => Package[$puppet_agent::package_name],
        logoutput => 'on_failure',
      }

      # package provider does not provide 'versionable'
      $ensure = 'present'
    } else {
      $ensure = $package_version
    }

    package { $::puppet_agent::package_name:
      ensure          => $ensure,
      provider        => 'rpm',
      source          => "/opt/puppetlabs/packages/${package_file_name}",
      install_options => $_install_options,
    }
  } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '10' {
    $_unzipped_package_name = regsubst($package_file_name, '\.gz$', '')
    $adminfile = '/opt/puppetlabs/packages/solaris-noask'
    $sourcefile = "/opt/puppetlabs/packages/${_unzipped_package_name}"
    $install_script = 'solaris_install.sh.erb'

    # Puppet prior to 5.0 would not use a separate process contract when forking from the Puppet
    # service. That resulted in service-initiated upgrades failing because trying to remove or
    # upgrade the package would stop the service, thereby killing the Puppet run. Use a script
    # to perform the upgrade after Puppet is done running.
    # Puppet 5.0 adds this, but some i18n implementation is loading code fairly late and appears
    # to be messing up the upgrade.
    if $old_packages or $puppet_agent::aio_upgrade_required {
      $old_package_names = $old_packages ? {
        true    => [
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
          default => ['puppet-agent'],
      }

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
  } elsif $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '11' and $old_packages {
    # Updating from PE 3.x requires removing all the old packages before installing the puppet-agent package.
    # After puppet-agent is installed, we can use 'pkg update' for future upgrades.
    contain puppet_agent::install::remove_packages

    exec { 'puppet_agent restore /etc/puppetlabs':
      command => 'cp -r /tmp/puppet_agent/puppetlabs /etc',
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      require => Class['puppet_agent::install::remove_packages'],
    }

    package { $::puppet_agent::package_name:
      ensure          => 'present',
      require         => Exec['puppet_agent restore /etc/puppetlabs'],
      notify          => Exec['puppet_agent post-install restore /etc/puppetlabs'],
      install_options => $install_options,
    }

    exec { 'puppet_agent post-install restore /etc/puppetlabs':
      command     => 'cp -r /tmp/puppet_agent/puppetlabs /etc',
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      refreshonly => true,
    }
  } elsif $::operatingsystem == 'Darwin' and $::macosx_productversion_major =~ /^10\.(9|10|11|12|13)/ {
    if $old_packages or $puppet_agent::aio_upgrade_required {
      $install_script = 'osx_install.sh.erb'

      contain puppet_agent::install::remove_packages

      $_logfile = "${::env_temp_variable}/osx_install.log"
      notice("Puppet install log file at ${_logfile}")

      $_installsh = "${::env_temp_variable}/osx_install.sh"
      file { "${_installsh}":
        ensure  => file,
        mode    => '0755',
        content => template('puppet_agent/do_install.sh.erb'),
        require => Class['Puppet_agent::Install::Remove_packages']
      }
      -> exec { 'osx_install script':
        command => "${_installsh} ${::puppet_agent_pid} 2>&1 > ${_logfile} &",
      }
    }
  } elsif $::osfamily == 'windows' {
    # Prevent re-running the batch install
    if $old_packages or $puppet_agent::aio_upgrade_required {
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
  } elsif ($::osfamily == 'RedHat') and ($package_version != 'present') {
    # Workaround PUP-5802/PUP-5025
    if ($::operatingsystem == 'Fedora') {
      if $pa_collection == 'PC1' or $pa_collection == 'puppet5' {
        # There's three cases here due to some mistakes with how we
        # set-up our distro tags for Fedora platforms:
        #   * For newer Fedora platforms (e.g. Fedora 28), we want
        #     to use the fc<major> tag
        #
        #   * For older Fedora platforms (e.g. Fedora 26 and 27), we
        #     have two separate cases:
        #       * If the package version's > 5.5.3, then we use the fedora<major>
        #         tag, b/c in those versions we removed the 'f' prefix.
        #
        #       * If the package version's <= 5.5.3, then we use the fedoraf<major>
        #         tag b/c the 'f' prefix is still there.
        #     
        if (versioncmp("${::operatingsystemmajrelease}", '27') > 0) {
          $dist_tag = "fc${::operatingsystemmajrelease}"
        } elsif (versioncmp("${package_version}", '5.5.3') > 0) {
          $dist_tag = "fedora${::operatingsystemmajrelease}"
        } else {
          $dist_tag = "fedoraf${::operatingsystemmajrelease}"
        }
      } else {
        $dist_tag = "fc${::operatingsystemmajrelease}"
      }
    } elsif ($::platform_tag != undef and $::platform_tag =~ /redhatfips.*/) {
      # The undef check here is for unit tests that don't supply this fact.
      $dist_tag = 'redhatfips7'
    } elsif $::operatingsystem == 'Amazon' {
      $dist_tag = 'el6'
    } else {
      $dist_tag = "el${::operatingsystemmajrelease}"
    }
    package { $::puppet_agent::package_name:
      ensure          => "${package_version}-1.${dist_tag}",
      install_options => $install_options,
    }
  } elsif ($::osfamily == 'Debian') and ($package_version != 'present') {
    # Workaround PUP-5802/PUP-5025
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
