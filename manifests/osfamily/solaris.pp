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
    '11': {
      class { 'puppet_agent::prepare::package':
        package_file_name => $package_file_name,
      }
      contain puppet_agent::prepare::package

      # Backup user configuration because solaris 11 will blow away
      # /etc/puppetlabs/ when uninstalling the pe-* modules.
      file { '/tmp/puppet_agent/':
        ensure => directory,
      }
      exec { 'puppet_agent backup /etc/puppetlabs/':
        command => 'cp -r /etc/puppetlabs/ /tmp/puppet_agent/',
        require => [Exec['puppet_agent copy packages'], File['/tmp/puppet_agent/']],
        path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      }

      $pkgrepo_dir = '/etc/puppetlabs/installer/solaris.repo'

      exec { 'puppet_agent remove existing repo':
        command   => "pkgrepo remove -s '${pkgrepo_dir}' '*'",
        path      => '/bin:/usr/bin:/sbin:/usr/sbin',
        onlyif    => "test -f ${pkgrepo_dir}/pkg5.repository",
        logoutput => 'on_failure',
        notify    => Exec['puppet_agent create repo'],
      }

      exec { 'puppet_agent create repo':
        command     => "pkgrepo create ${pkgrepo_dir}",
        path        => '/bin:/usr/bin:/sbin:/usr/sbin',
        unless      => "test -f ${pkgrepo_dir}/pkg5.repository",
        logoutput   => 'on_failure',
        notify      => Exec['puppet_agent set publisher'],
        refreshonly => true,
      }

      exec { 'puppet_agent set publisher':
        command     => "pkgrepo set -s ${pkgrepo_dir} publisher/prefix=puppetlabs.com",
        path        => '/bin:/usr/bin:/sbin:/usr/sbin',
        logoutput   => 'on_failure',
        refreshonly => true,
      }

      exec { 'puppet_agent copy packages':
        command   => "pkgrecv -s file:///opt/puppetlabs/packages/${package_file_name} -d ${pkgrepo_dir} '*'",
        path      => '/bin:/usr/bin:/sbin:/usr/sbin',
        require   => Exec['puppet_agent set publisher'],
        logoutput => 'on_failure',
      }

    }
    default: {
      fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
    }
  }
}
