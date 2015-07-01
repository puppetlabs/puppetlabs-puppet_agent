class puppet_agent::osfamily::redhat {
  assert_private()

  if $::operatingsystem == 'Fedora' {
    $urlbit = 'fedora/f$releasever'
  }
  else {
    $urlbit = 'el/$releasever'
  }

  if $::is_pe {
    # If this is PE, we're using a self signed certificate, so need to disable SSL verification
    $sslverify = 'False'
    $pe_server_version = pe_build_version()
    $source = "${::puppet_agent::source}/${pe_server_version}/${::platform_tag}"
  }
  else {
    $sslverify = 'True'
    $source = $::puppet_agent::source ? {
      undef   => "https://yum.puppetlabs.com/${urlbit}/PC1/${::architecture}",
      default => $::puppet_agent::source,
    }
  }

  $keyname = 'RPM-GPG-KEY-puppetlabs'
  $gpg_path = "/etc/pki/rpm-gpg/${keyname}"

  file { ['/etc/pki', '/etc/pki/rpm-gpg']:
    ensure => directory,
  }

  file { $gpg_path:
    ensure => present,
    owner  => 0,
    group  => 0,
    mode   => '0644',
    source => "puppet:///modules/puppet_agent/${keyname}",
  }

  # Given the path to a key, see if it is imported, if not, import it
  exec {  "import-${keyname}":
    path      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command   => "rpm --import ${gpg_path}",
    unless    => "rpm -q gpg-pubkey-`echo $(gpg --throw-keyids < ${gpg_path}) | cut --characters=11-18 | tr [A-Z] [a-z]`",
    require   => File[$gpg_path],
    logoutput => 'on_failure',
  }

  yumrepo { 'pc1_repo':
    baseurl   => $source,
    descr     => "Puppet Labs PC1 Repository",
    enabled   => true,
    gpgcheck  => '1',
    gpgkey    => "file://$gpg_path",
    sslverify => $sslverify,
  }
}

