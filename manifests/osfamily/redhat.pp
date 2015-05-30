class puppet_agent::osfamily::redhat {
  if $::operatingsystem == 'Fedora' {
    $urlbit = 'fedora/f$releasever'
  }
  else {
    $urlbit = 'el/$releasever'
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
    baseurl  => "https://yum.puppetlabs.com/${urlbit}/PC1/${::architecture}",
    descr    => "Puppet Labs PC1 Repository",
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => "file://$gpg_path",
  }
}

