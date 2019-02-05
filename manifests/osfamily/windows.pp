class puppet_agent::osfamily::windows{
  assert_private()
  if $::puppet_agent::is_pe {
    $pe_server_version = pe_build_version()
    $tag = $::puppet_agent::arch ? {
      'x64' => 'windows-x86_64',
      'x86' => 'windows-i386',
    }
    $source = "puppet:///pe_packages/${pe_server_version}/${tag}/${::puppet_agent::package_name}-${::puppet_agent::arch}.msi"
  } else {
    $source = "https://downloads.puppet.com/windows/${::puppet_agent::collection}/${::puppet_agent::package_name}-${::puppet_agent::package_version}-${::puppet_agent::arch}.msi"
  }

  class { '::puppet_agent::prepare::package':
    source => $source,
  }
  contain puppet_agent::prepare::package
}
