class puppet_agent::osfamily::debian(
  $package_file_name = undef,
) {
  assert_private()

  if $::puppet_agent::manage_repo {

    include ::apt

    if $::puppet_agent::is_pe {
      $pe_server_version = pe_build_version()
      $source = "${::puppet_agent::source}/${pe_server_version}/${::platform_tag}"

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
      $_client_cert_verification = [
        "Acquire::https::${source_host}::SslCert \"${_sslclientcert_path}\";",
        "Acquire::https::${source_host}::SslKey \"${_sslclientkey_path}\";",
      ]
      $_ca_cert_verification = [
        "Acquire::https::${source_host}::CaInfo \"${_sslcacert_path}\";",
      ]
      $_proxy_host = [
        "Acquire::http::proxy::${source_host} DIRECT;",
      ]

      # Xenial has some sort of change that seems to have broke client cert
      # verification in APT. While it is nice to have client cert verification,
      # it is not strictly necessary since really all that we want to verify is
      # that there isn't a MITM on the route to the master.
      if ($::operatingsystem == 'Ubuntu' and $::lsbdistcodename == 'xenial') {
        $_apt_settings = concat(
          $_ca_cert_verification,
          $_proxy_host)
      } else {
        $_apt_settings = concat(
          $_ca_cert_verification,
          $_client_cert_verification,
          $_proxy_host)
      }

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
    }
    else {
      $source = $::puppet_agent::source ? {
        undef   => 'http://apt.puppetlabs.com',
        default => $::puppet_agent::source,
      }
    }

    apt::key { 'legacy key':
      id     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      server => 'pgp.mit.edu',
    }

    apt::source { 'pc_repo':
      location => $source,
      repos    => $::puppet_agent::collection,
      key      => {
        'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
        'server' => 'pgp.mit.edu',
      },
      notify   => Notify['pc_repo_force'],
    }

    # apt_update doesn't inherit the future class dependency, so it
    # can wait until the end of the run to exec. Force it to happen now.
    notify { 'pc_repo_force':
        message => "forcing apt update for pc_repo ${::puppet_agent::collection}",
        require => Exec['apt_update'],
    }

  }
}
