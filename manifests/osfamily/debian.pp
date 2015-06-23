class puppet_agent::osfamily::debian {
  include apt

  apt::source { 'pc1_repo':
    location   => 'http://apt.puppetlabs.com',
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
