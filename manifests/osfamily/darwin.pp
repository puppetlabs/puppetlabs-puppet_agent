# @summary Used to determine the puppet-agent package location for Darwin OSes.
class puppet_agent::osfamily::darwin {
  assert_private()

  if $facts['os']['macosx']['version']['major'] =~ /^10\./ {
    $productversion_major = $facts['os']['macosx']['version']['major']
  } else {
    $productversion_array = split($facts['os']['macosx']['version']['major'], '[.]')
    $productversion_major = $productversion_array[0]
  }

  if $puppet_agent::absolute_source {
    $source = $puppet_agent::absolute_source
  } elsif ($puppet_agent::is_pe and (!$puppet_agent::use_alternate_sources)) {
    $pe_server_version = pe_build_version()
    if $puppet_agent::alternate_pe_source {
      $source = "${puppet_agent::alternate_pe_source}/packages/${pe_server_version}/${facts['platform_tag']}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.osx${$productversion_major}.dmg"
    } elsif $puppet_agent::source {
      $source = "${puppet_agent::source}/packages/${pe_server_version}/${facts['platform_tag']}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.osx${$productversion_major}.dmg"
    } else {
      $source = "puppet:///pe_packages/${pe_server_version}/${facts['platform_tag']}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.osx${$productversion_major}.dmg"
    }
  } elsif $puppet_agent::collection =~ /core/ {
    $source = 'https://artifacts-puppetcore.puppet.com/v1/download'
  } else {
    $source = "${puppet_agent::mac_source}/mac/${puppet_agent::collection}/${productversion_major}/${puppet_agent::arch}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.osx${$productversion_major}.dmg"
  }

  $destination_name = if $puppet_agent::collection =~ /core/ {
    "${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-1.osx${$productversion_major}.dmg"
  } else {
    undef
  }

  class { 'puppet_agent::prepare::package':
    source           => $source,
    destination_name => $destination_name,
  }

  contain puppet_agent::prepare::package
}
