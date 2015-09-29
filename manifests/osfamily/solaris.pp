class puppet_agent::osfamily::solaris(
  $package_file_name = undef,
) {
  assert_private()

  if $::operatingsystem != 'Solaris' or $::puppet_agent::is_pe == false {
    fail("${::operatingsystem} not supported")
  }

  case $::operatingsystemmajrelease {
    '10': {
      class { 'puppet_agent::prepare::package':
        package_file_name => $package_file_name,
      }
      contain puppet_agent::prepare::package

      $_unzipped_package_name = regsubst($package_file_name, '\.gz$', '')
      exec { "unzip ${package_file_name}":
        path      => '/bin:/usr/bin:/sbin:/usr/sbin',
        command   => "gzip -d /opt/puppetlabs/packages/${package_file_name}",
        creates   => "/opt/puppetlabs/packages/${_unzipped_package_name}",
        require   => Class['puppet_agent::prepare::package'],
        logoutput => 'on_failure',
      }

      $pe_server_version = pe_build_version()
      file { '/opt/puppetlabs/packages/solaris-noask':
        ensure => present,
        owner  => 0,
        group  => 0,
        mode   => '0644',
        source => "puppet:///pe_packages/${pe_server_version}/${::platform_tag}/solaris-noask",
      }
    }
    default: {
      fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
    }
  }
}
