class puppet_agent::osfamily::aix{
  assert_private()

  if $::operatingsystem != 'AIX' {
    fail("${::operatingsystem} not supported")
  }

  if $::puppet_agent::is_pe != true {
    fail('AIX upgrades are only supported on Puppet Enterprise')
  }

  $pe_server_version = pe_build_version()

  # in puppet versions later than 4 we began using single agent packages for
  # multiple version of AIX. The support sequence is as follows:
  #
  # puppet 4:
  #     * AIX verison 6.1 < aix-6.1-power package
  #     * AIX verison 7.1 < aix-7.1-power package
  #
  # puppet 5:
  #     * AIX verison 6.1 < aix-6.1-power package
  #     * AIX verison 7.1 < aix-7.1-power package
  #     * AIX verison 7.2 < aix-7.1-power package
  #
  # puppet 6:
  #     * AIX verison 6.1 < aix-6.1-power package
  #     * AIX verison 7.1 < aix-6.1-power package
  #     * AIX verison 7.2 < aix-6.1-power package
  #
  # For puppet > 6 everything will now _only_ use the aix-6.1-power packages (i.e. we now only ship
  # one package to support all aix versions).
  #
  # The following will update the aix_ver_number variable to identify which package to install based
  # on puppet collection and version of AIX.
  $_aix_ver_number = regsubst($::platform_tag,'aix-(\d+\.\d+)-power','\1')
  if $_aix_ver_number {
    if $::puppet_agent::collection =~ /(PC1|puppet5)/ {
      $aix_ver_number = $_aix_ver_number ? {
        /^7\.2$/ => '7.1',
        default  => $_aix_ver_number,
      }
    } else {
      $aix_ver_number = '6.1'
    }
  }
  if $::puppet_agent::absolute_source {
    $source = $::puppet_agent::absolute_source
  } elsif $::puppet_agent::alternate_pe_source {
    $source = "${::puppet_agent::alternate_pe_source}/packages/${pe_server_version}/aix-${aix_ver_number}-power/${::puppet_agent::package_name}-${::puppet_agent::package_version}-1.aix${aix_ver_number}.ppc.rpm"
  } elsif $::puppet_agent::source {
    $source = "${::puppet_agent::source}/packages/${pe_server_version}/aix-${aix_ver_number}-power/${::puppet_agent::package_name}-${::puppet_agent::package_version}-1.aix${aix_ver_number}.ppc.rpm"
  } else {
    $source = "${::puppet_agent::aix_source}/${pe_server_version}/aix-${aix_ver_number}-power/${::puppet_agent::package_name}-${::puppet_agent::package_version}-1.aix${aix_ver_number}.ppc.rpm"
  }

  class { '::puppet_agent::prepare::package':
    source => $source,
  }
  contain puppet_agent::prepare::package
}
