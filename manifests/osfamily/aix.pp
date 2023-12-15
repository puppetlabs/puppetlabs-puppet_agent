# @summary Used to determine the puppet-agent package location for AIX OSes.
class puppet_agent::osfamily::aix {
  assert_private()

  if $facts['os']['name'] != 'AIX' {
    fail("${facts['os']['name']} not supported")
  }

  if $puppet_agent::is_pe != true {
    fail('AIX upgrades are only supported on Puppet Enterprise')
  }

  $pe_server_version = pe_build_version()

  # in puppet versions later than 4 we began using single agent packages for
  # multiple version of AIX. The support sequence is as follows:
  #
  # puppet 5 up to 5.5.22:
  #     * AIX version 6.1 < aix-6.1-power package
  #     * AIX version 7.1 < aix-7.1-power package
  #     * AIX version 7.2 < aix-7.1-power package
  #
  # puppet 6 up to 6.19.1 and puppet 7.0.0:
  #     * AIX version 6.1 < aix-7.1-power package
  #     * AIX version 7.1 < aix-7.1-power package
  #     * AIX version 7.2 < aix-7.1-power package
  #     * AIX version 7.3 < aix-7.1-power package
  #
  # puppet 8:
  #     * AIX version 7.2 < aix-7.2-power package
  #     * AIX version 7.3 < aix-7.2-power package
  #
  # All other versions will now _only_ use the aix-7.1-power packages (i.e. we now only ship
  # one package to support all aix versions).
  #
  # The following will update the aix_ver_number variable to identify which package to install based
  # on puppet collection, package version and AIX version.
  $_aix_ver_number = regsubst($facts['platform_tag'],'aix-(\d+\.\d+)-power','\1')
  if $_aix_ver_number {
    if $puppet_agent::collection =~ /^puppet8/ {
      $aix_ver_number = '7.2'
    } elsif $puppet_agent::collection =~ /^puppet7/ {
      $aix_ver_number = '7.1'
    } else {
      # 6.19.1 is the last puppet6 release that ships AIX 6.1 packages

      $aix_ver_number = versioncmp($puppet_agent::prepare::package_version, '6.19.1') ? {
        1       => '7.1',
        default => '6.1'
      }
    }
  }

  $aix_class_name = if (versioncmp($pe_server_version, '2021.7.7') < 0) or (versioncmp($pe_server_version, '2023.0') >= 0 and versioncmp($pe_server_version, '2023.6') < 0) {
    "aix-${aix_ver_number}-power"
  } else {
    'aix-power'
  }

  if $puppet_agent::absolute_source {
    $source = $puppet_agent::absolute_source
  } elsif $puppet_agent::alternate_pe_source {
    $source = "${puppet_agent::alternate_pe_source}/packages/${pe_server_version}/${aix_class_name}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.aix${aix_ver_number}.ppc.rpm"
  } elsif $puppet_agent::source {
    $source = "${puppet_agent::source}/packages/${pe_server_version}/${aix_class_name}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.aix${aix_ver_number}.ppc.rpm"
  } else {
    $source = "${puppet_agent::aix_source}/${pe_server_version}/${aix_class_name}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.aix${aix_ver_number}.ppc.rpm"
  }

  class { 'puppet_agent::prepare::package':
    source => $source,
  }
  contain puppet_agent::prepare::package
}
