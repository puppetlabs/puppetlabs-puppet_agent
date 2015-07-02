class puppet_agent::osfamily::debian {
  assert_private()

  include apt

  if $::puppet_agent::is_pe {
    $pe_server_version = pe_build_version()
    $source = "${::puppet_agent::source}/${pe_server_version}/${::platform_tag}"
    $source_host = uri_host_from_string($source)

    # If this is PE, we're using a self signed certificate, so need to disable SSL verification
    apt::setting { 'conf-pc1_repo':
      content  => "Acquire::https::${source_host}::Verify-Peer false;\nAcquire::http::Proxy::${source_host} DIRECT;",
      priority => 90,
    }
  }
  else {
    $source = $::puppet_agent::source ? {
      undef   => 'http://apt.puppetlabs.com',
      default => $::puppet_agent::source,
    }
  }


  apt::source { 'pc1_repo':
    location   => $source,
    repos      => 'PC1',
    key        => {
      'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      'server' => 'pgp.mit.edu',
    },
    notify     => Notify['pc1_repo_force'],
  }

  # apt_update doesn't inherit the future class dependency, so it
  # can wait until the end of the run to exec. Force it to happen now.
  notify { 'pc1_repo_force':
      message => 'forcing apt update for pc1_repo',
      require => Exec['apt_update'],
  }
}
