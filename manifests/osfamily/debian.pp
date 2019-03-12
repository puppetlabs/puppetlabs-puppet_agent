class puppet_agent::osfamily::debian{
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
    if getvar('::puppet_agent::manage_repo') == true {
      include ::apt
      if ($::puppet_agent::is_pe and (!$::puppet_agent::use_alternate_sources)) {
        $pe_server_version = pe_build_version()
        if $::puppet_agent::source {
          $source = "${::puppet_agent::source}/packages/${pe_server_version}/${::platform_tag}"
        } elsif $::puppet_agent::alternate_pe_source {
          $source = "${::puppet_agent::alternate_pe_source}/packages/${pe_server_version}/${::platform_tag}"
        } else {
          $source = "https://${::puppet_master_server}:8140/packages/${pe_server_version}/${::platform_tag}"
        }
        # In Puppet Enterprise, agent packages are served by the same server
        # as the master, which can be using either a self signed CA, or an external CA.
        # In order for apt to authenticate to the repo on the PE Master, it will need
        # to be configured to pass in the agents certificates. By the time this code is called,
        # the module has already moved the certs to $ssl_dir/{certs,private_keys}, which
        # happen to be the default in PE already.
        $_ssl_dir = $::puppet_agent::params::ssldir
        $_sslcacert_path = "${_ssl_dir}/certs/ca.pem"
        $_sslclientcert_path = "${_ssl_dir}/certs/${::clientcert}.pem"
        $_sslclientkey_path = "${_ssl_dir}/private_keys/${::clientcert}.pem"

        # For debian based platforms, in order to add SSL verification, you need to add a
        # configuration file specific to just the sources host
        $source_host = uri_host_from_string($source)
        $_ca_cert_verification = [
          "Acquire::https::${source_host}::CaInfo \"${_sslcacert_path}\";",
        ]
        $_proxy_host = [
          "Acquire::http::proxy::${source_host} DIRECT;",
        ]

        $_apt_settings = concat(
          $_ca_cert_verification,
          $_proxy_host)


        apt::setting { 'conf-pc_repo':
          content  => $_apt_settings.join(''),
          priority => 90,
        }

        # Due to the file paths changing on the PE Master, the 3.8 repository is no longer valid.
        # On upgrade, remove the repo file so that a dangling reference is not left behind returning
        # a 404 on subsequent runs.

        # Pass in an empty content string since apt requires it even though we are removing it
        apt::setting {'list-puppet-enterprise-installer':
          ensure  => absent,
          content => '',
        }

        apt::setting { 'conf-pe-repo':
          ensure   => absent,
          priority => '90',
          content  => '',
        }
      } else {
        $source = $::puppet_agent::apt_source
      }
      $legacy_keyname = 'GPG-KEY-puppetlabs'
      $legacy_gpg_path = "/etc/pki/deb-gpg/${legacy_keyname}"
      $keyname = 'GPG-KEY-puppet'
      $gpg_path = "/etc/pki/deb-gpg/${keyname}"

      if getvar('::puppet_agent::manage_pki_dir') == true {
        file { ['/etc/pki', '/etc/pki/deb-gpg']:
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

      apt::key { 'legacy key':
        id     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
        source => $legacy_gpg_path,
      }

      file { $gpg_path:
        ensure => present,
        owner  => 0,
        group  => 0,
        mode   => '0644',
        source => "puppet:///modules/puppet_agent/${keyname}",
      }

      apt::source { 'pc_repo':
        location => $source,
        repos    => $::puppet_agent::collection,
        key      => {
          'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
          'source' => $gpg_path,
        },
        notify   => Exec['pc_repo_force'],
      }

      # apt_update doesn't inherit the future class dependency, so it
      # can wait until the end of the run to exec. Force it to happen now.
      exec { 'pc_repo_force':
        command     => "/bin/echo 'forcing apt update for pc_repo ${::puppet_agent::collection}'",
        refreshonly => true,
        logoutput   => true,
        subscribe   => Exec['apt_update'],
      }
    }
  }
}
