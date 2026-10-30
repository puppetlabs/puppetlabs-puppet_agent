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

  # puppet-agent packages for AIX are built on a single AIX version and installed
  # on every supported AIX version. The support sequence is as follows:
  #
  # puppet 7:
  #     * AIX version 7.1 < aix-7.1-power package
  #     * AIX version 7.2 < aix-7.1-power package
  #     * AIX version 7.3 < aix-7.1-power package
  #
  # puppet 8 and later:
  #     * AIX version 7.2 < aix-7.2-power package
  #     * AIX version 7.3 < aix-7.2-power package
  #
  # The following will update the aix_ver_number variable to identify which package to install based
  # on the puppet collection. Collections older than puppet7 are no longer supported and fall back to
  # the aix-7.1-power package.
  $_aix_ver_number = regsubst($facts['platform_tag'],'aix-(\d+\.\d+)-power','\1')
  if $_aix_ver_number {
    $_collection_match = $puppet_agent::collection.match(/^puppet(\d+)/)
    if $_collection_match and Integer($_collection_match[1]) >= 8 {
      $aix_ver_number = '7.2'
    } else {
      $aix_ver_number = '7.1'
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
