class agent_upgrade::puppetlabs_yum {

  if $::osfamily == 'RedHat' {
    if $::operatingsystem == 'Fedora' {
      $urlbit = 'fedora/f$releasever'
    } else {
      $urlbit = 'el/$releasever'
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
    source => "puppet:///modules/agent_upgrade/${keyname}",
  }

  agent_upgrade::rpm_gpg_key{ $keyname:
    path    => $gpg_path,
  }

  yumrepo { 'pc1_repo':
    baseurl  => "https://yum.puppetlabs.com/${urlbit}/PC1/${::architecture}",
    descr    => "Puppet Labs PC1 Repository",
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => "file://$gpg_path",
  }
}
