class puppet_agent::osfamily::redhat(
  $package_file_name = undef,
) {
  assert_private()

  if $::operatingsystem == 'Fedora' {
    $urlbit = 'fedora/f$releasever'
  }
  else {
    $urlbit = 'el/$releasever'
  }

  if $::puppet_agent::is_pe {
    # In Puppet Enterprise, agent packages are served by the same server
    # as the master, which can be using either a self signed CA, or an external CA.
    # In order for yum to authenticate to the yumrepo on the PE Master, it will need
    # to be configured to pass in the agents certificates. By the time this code is called,
    # the module has already moved the certs to $ssl_dir/{certs,private_keys}, which
    # happen to be the default in PE already.

    $_ssl_dir = $::puppet_agent::params::ssldir
    $_sslcacert_path = "${_ssl_dir}/certs/ca.pem"
    $_sslclientcert_path = "${_ssl_dir}/certs/${::clientcert}.pem"
    $_sslclientkey_path = "${_ssl_dir}/private_keys/${::clientcert}.pem"

    $pe_server_version = pe_build_version()
    $source = "${::puppet_agent::source}/${pe_server_version}/${::platform_tag}"

    # Due to the file paths changing on the PE Master, the 3.8 repository is no longer valid.
    # On upgrade, remove the repo file so that a dangling reference is not left behind returning
    # a 404 on subsequent runs.
    yumrepo { 'puppetlabs-pepackages':
      ensure => absent,
    }
  }
  else {
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
    baseurl       => $source,
    descr         => 'Puppet Labs PC1 Repository',
    enabled       => true,
    gpgcheck      => '1',
    gpgkey        => "file://${gpg_path}",
    sslcacert     => $_sslcacert_path,
    sslclientcert => $_sslclientcert_path,
    sslclientkey  => $_sslclientkey_path,
  }
}

