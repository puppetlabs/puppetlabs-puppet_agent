class puppet_agent::osfamily::debian {
  include apt

  apt::source { 'pc1_repo':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'PC1',
    key        => {
      'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      'server' => 'pgp.mit.edu',
    }
  }
}
