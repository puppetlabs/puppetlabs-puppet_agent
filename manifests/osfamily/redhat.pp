class puppet_agent::osfamily::redhat{
  assert_private()

  if $::puppet_agent::absolute_source {
    # Absolute sources are expected to be actual packages (not repos)
    # so when absolute_source is set just download the package to the
    # system and finish with this class.
    $source = $::puppet_agent::absolute_source
    class { '::puppet_agent::prepare::package':
      source => $source,
    }
    contain puppet_agent::prepare::package
  } else {
    case $::operatingsystem {
      'Fedora': {
        $platform_and_version = "fedora/${::operatingsystemmajrelease}"
      }
      'Amazon': {
        $platform_and_version = 'el/6'
      }
      default: {
        $platform_and_version = "el/${::operatingsystemmajrelease}"
      }
    }
    if ($::puppet_agent::is_pe and (!$::puppet_agent::use_alternate_sources)) {
      $pe_server_version = pe_build_version()
      # Treat Amazon Linux just like Enterprise Linux 6
      $pe_repo_dir = ($::operatingsystem == 'Amazon') ? {
        true    => "el-6-${::architecture}",
        default =>  $::platform_tag,
      }
      if $::puppet_agent::source {
        $source = "${::puppet_agent::source}/packages/${pe_server_version}/${pe_repo_dir}"
      } elsif $::puppet_agent::alternate_pe_source {
        $source = "${::puppet_agent::alternate_pe_source}/packages/${pe_server_version}/${pe_repo_dir}"
      } else {
        $source = "https://${::puppet_master_server}:8140/packages/${pe_server_version}/${pe_repo_dir}"
      }
    } else {
      if $::puppet_agent::collection == 'PC1' {
        $source = "${::puppet_agent::yum_source}/${platform_and_version}/${::puppet_agent::collection}/${::puppet_agent::arch}"
      } else {
        $source = "${::puppet_agent::yum_source}/${::puppet_agent::collection}/${platform_and_version}/${::puppet_agent::arch}"
      }
    }


    if ($::puppet_agent::is_pe  and (!$::puppet_agent::use_alternate_sources)) {
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
      # Due to the file paths changing on the PE Master, the 3.8 repository is no longer valid.
      # On upgrade, remove the repo file so that a dangling reference is not left behind returning
      # a 404 on subsequent runs.
      yumrepo { 'puppetlabs-pepackages':
        ensure => absent,
      }
    }
    else {
      $_sslcacert_path = undef
      $_sslclientcert_path = undef
      $_sslclientkey_path = undef
    }

    # Fedora doesn't ship with a gpg binary, only gpg2
    if $::operatingsystem == 'Fedora' {
      $gpg_cmd = 'gpg2'
    } else {
      $gpg_cmd = 'gpg'
    }

    $legacy_keyname = 'GPG-KEY-puppetlabs'
    $legacy_gpg_path = "/etc/pki/rpm-gpg/RPM-${legacy_keyname}"
    $keyname = 'GPG-KEY-puppet'
    $gpg_path = "/etc/pki/rpm-gpg/RPM-${keyname}"
    $gpg_keys = "file://${legacy_gpg_path}
  file://${gpg_path}"

    if $::puppet_agent::manage_pki_dir == true {
      file { ['/etc/pki', '/etc/pki/rpm-gpg']:
        ensure => directory,
      }
    }

    file { $legacy_gpg_path:
      ensure => present,
      owner  => 0,
      group  => 0,
      mode   => '0644',
      source => "puppet:///modules/puppet_agent/${legacy_keyname}",
    }

    # Given the path to a key, see if it is imported, if not, import it
    $legacy_gpg_pubkey = "gpg-pubkey-$(echo $(${gpg_cmd} --with-colons ${legacy_gpg_path} 2>&1 | grep ^pub | awk -F ':' '{print \$5}' | cut --characters=9-16 | tr '[:upper:]' '[:lower:]'))"

    exec {  "import-${legacy_keyname}":
      path      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command   => "rpm --import ${legacy_gpg_path}",
      unless    => "rpm -q ${legacy_gpg_pubkey}",
      require   => File[$legacy_gpg_path],
      logoutput => 'on_failure',
    }

    file { $gpg_path:
      ensure => present,
      owner  => 0,
      group  => 0,
      mode   => '0644',
      source => "puppet:///modules/puppet_agent/${keyname}",
    }

    # Given the path to a key, see if it is imported, if not, import it
    $gpg_pubkey = "gpg-pubkey-$(echo $(${gpg_cmd} --with-colons ${gpg_path} 2>&1 | grep ^pub | awk -F ':' '{print \$5}' | cut --characters=9-16 | tr '[:upper:]' '[:lower:]'))"
    exec {  "import-${keyname}":
      path      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command   => "rpm --import ${gpg_path}",
      unless    => "rpm -q ${gpg_pubkey}",
      require   => File[$gpg_path],
      logoutput => 'on_failure',
    }

    if $::puppet_agent::manage_repo == true {
      $_proxy = $::puppet_agent::disable_proxy ? {
        true    => '_none_',
        default => undef,
      }
      yumrepo { 'pc_repo':
        baseurl             => $source,
        descr               => "Puppet Labs ${::puppet_agent::collection} Repository",
        enabled             => true,
        gpgcheck            => '1',
        gpgkey              => "${gpg_keys}",
        proxy               => $_proxy,
        sslcacert           => $_sslcacert_path,
        sslclientcert       => $_sslclientcert_path,
        sslclientkey        => $_sslclientkey_path,
        skip_if_unavailable => $::puppet_agent::skip_if_unavailable,
      }
    }
  }
}
