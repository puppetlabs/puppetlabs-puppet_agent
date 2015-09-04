# == Class puppet_agent::install::default
#
# Private class called from puppet_agent::install class
#
# Manage the install process for systems using their default package provider
#
class puppet_agent::install::default (
  $package_file_name = undef,
  $version
) {
  assert_private()

  if $version == undef {
    $version = 'present'
  }

  if ($::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '10') or ($::operatingsystem == 'AIX' and  $::architecture =~ 'PowerPC_POWER[5,6,7]') {
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
      adminfile => '/opt/puppetlabs/packages/solaris-noask',
      source    => "/opt/puppetlabs/packages/${_unzipped_package_name}",
      require   => Class['puppet_agent::install::remove_packages'],
    }
  } elsif $::operatingsystem == 'Darwin' and $::macosx_productversion_major =~ '10\.[9,10,11]' {
    contain puppet_agent::install::remove_packages

    $_package_options = {
      source    => "/opt/puppetlabs/packages/${package_file_name}",
      require   => Class['puppet_agent::install::remove_packages'],
    }
  } else {
    $_package_options = {}
  }

  package { $::puppet_agent::package_name:
    ensure => $version,
    *      => $_package_options,
  }
}
