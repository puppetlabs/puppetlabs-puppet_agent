# @summary Determines the puppet-agent package location for Windows OSes.
class puppet_agent::osfamily::windows {
  assert_private()

  if $puppet_agent::absolute_source {
    $source = $puppet_agent::absolute_source
  } elsif $puppet_agent::source {
    $source = $puppet_agent::source
  } elsif  ($puppet_agent::is_pe and (!$puppet_agent::use_alternate_sources)) {
    $pe_server_version = pe_build_version()
    $tag = $puppet_agent::arch ? {
      'x64' => $facts['fips_enabled'] ? {
        true => 'windowsfips-x86_64',
        default => 'windows-x86_64'
      },
      'x86' => 'windows-i386'
    }
    if $puppet_agent::alternate_pe_source {
      $source = "${puppet_agent::alternate_pe_source}/packages/${pe_server_version}/${tag}/${puppet_agent::package_name}-${puppet_agent::arch}.msi"
    } else {
      $source = "puppet:///pe_packages/${pe_server_version}/${tag}/${puppet_agent::package_name}-${puppet_agent::arch}.msi"
    }
  } else {
    if $puppet_agent::collection == 'PC1' {
      $source = "${puppet_agent::windows_source}/windows/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-${puppet_agent::arch}.msi"
    } elsif $puppet_agent::collection =~ /core/ {
      $source = 'https://artifacts-puppetcore.puppet.com/v1/download'
    } else {
      $source = "${puppet_agent::windows_source}/windows/${puppet_agent::collection}/${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-${puppet_agent::arch}.msi"
    }
  }

  $destination_name = if $puppet_agent::collection =~ /core/ {
    "${puppet_agent::package_name}-${puppet_agent::prepare::package_version}-${puppet_agent::arch}.msi"
  } else {
    undef
  }

  class { 'puppet_agent::prepare::package':
    source           => $source,
    destination_name => $destination_name,
  }

  contain puppet_agent::prepare::package
}
