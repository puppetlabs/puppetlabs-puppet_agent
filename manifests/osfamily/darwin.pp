class puppet_agent::osfamily::darwin{
  assert_private()

  if $::puppet_agent::absolute_source {
    $source = $::puppet_agent::absolute_source
  } elsif ($::puppet_agent::is_pe and (!$::puppet_agent::use_alternate_sources)) {
    $pe_server_version = pe_build_version()
    if $::puppet_agent::alternate_pe_source {
      $source = "${::puppet_agent::alternate_pe_source}/packages/${pe_server_version}/${::platform_tag}/${puppet_agent::package_name}-${puppet_agent::package_version}-1.osx${$::macosx_productversion_major}.dmg"
    } elsif $::puppet_agent::source {
      $source = "${::puppet_agent::source}/packages/${pe_server_version}/${::platform_tag}/${puppet_agent::package_name}-${puppet_agent::package_version}-1.osx${$::macosx_productversion_major}.dmg"
    } else {
      $source = "puppet:///pe_packages/${pe_server_version}/${::platform_tag}/${puppet_agent::package_name}-${puppet_agent::package_version}-1.osx${$::macosx_productversion_major}.dmg"
    }
  } else {
    $source = "${::puppet_agent::mac_source}/mac/${::puppet_agent::collection}/${::macosx_productversion_major}/${::puppet_agent::arch}/${puppet_agent::package_name}-${puppet_agent::package_version}-1.osx${$::macosx_productversion_major}.dmg"
  }
  class { '::puppet_agent::prepare::package':
    source => $source,
  }

  contain puppet_agent::prepare::package
}
