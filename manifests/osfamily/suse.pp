class puppet_agent::osfamily::suse(
  $package_file_name = undef,
) {
  assert_private()

  if $::operatingsystem != 'SLES' {
    fail("${::operatingsystem} not supported")
  }

  $collection = getvar('::puppet_agent::collection')

  if $collection == 'PC1' and $::operatingsystemmajrelease !~ /(11|12)/ {
    fail("Puppet 4 is not supported on SLES ${::operatingsystemmajrelease}")
  }

  case $::operatingsystemmajrelease {
    '11', '12', '15': {
      # Import the GPG key
      $legacy_keyname  = 'GPG-KEY-puppetlabs'
      $legacy_gpg_path = "/etc/pki/rpm-gpg/RPM-${legacy_keyname}"
      $keyname         = 'GPG-KEY-puppet'
      $gpg_path        = "/etc/pki/rpm-gpg/RPM-${keyname}"
      $gpg_homedir     = '/root/.gnupg'

      if getvar('::puppet_agent::manage_pki_dir') == true {
        file { ['/etc/pki', '/etc/pki/rpm-gpg']:
          ensure => directory,
        }
      }

      file { $gpg_path:
        ensure => present,
        owner  => 0,
        group  => 0,
        mode   => '0644',
        source => "puppet:///modules/puppet_agent/${keyname}",
      }

      file { $legacy_gpg_path:
        ensure => present,
        owner  => 0,
        group  => 0,
        mode   => '0644',
        source => "puppet:///modules/puppet_agent/${legacy_keyname}",
      }

      # Given the path to a key, see if it is imported, if not, import it
      $legacy_gpg_pubkey = "gpg-pubkey-$(echo $(gpg --homedir ${gpg_homedir} --throw-keyids < ${legacy_gpg_path})"
      $gpg_pubkey = "gpg-pubkey-$(echo $(gpg --homedir ${gpg_homedir} --throw-keyids < ${gpg_path})"

      exec { "import-${legacy_keyname}":
        path      => '/bin:/usr/bin:/sbin:/usr/sbin',
        command   => "rpm --import ${legacy_gpg_path}",
        unless    => "rpm -q ${legacy_gpg_pubkey} | cut --characters=11-18 | tr [:upper:] [:lower:])",
        require   => File[$legacy_gpg_path],
        logoutput => 'on_failure',
      }

      exec { "import-${keyname}":
        path      => '/bin:/usr/bin:/sbin:/usr/sbin',
        command   => "rpm --import ${gpg_path}",
        unless    => "rpm -q ${gpg_pubkey} | cut --characters=11-18 | tr [:upper:] [:lower:])",
        require   => File[$gpg_path],
        logoutput => 'on_failure',
      }

      if getvar('::puppet_agent::manage_repo') == true {
        # Set up a zypper repository by creating a .repo file which mimics a ini file
        if getvar('::puppet_agent::is_pe') == true {
          $pe_server_version = pe_build_version()
          $source = "${::puppet_agent::source}/${pe_server_version}/${::platform_tag}"
        } else {
          if $collection =~ /(?i:PC1)/ {
            $_default_source = "https://yum.puppet.com/sles/${::operatingsystemmajrelease}/PC1/${::architecture}"
          } else {
            $_default_source = "https://yum.puppet.com/${collection}/sles/${::operatingsystemmajrelease}/${::architecture}"
          }

          $source = getvar('::puppet_agent::source') ? {
            undef   => $_default_source,
            default => getvar('::puppet_agent::source'),
          }
        }

        $repo_file = '/etc/zypp/repos.d/pc_repo.repo'
        $repo_name = 'pc_repo'
        $agent_version = $::puppet_agent::package_version

        # In Puppet Enterprise, agent packages are served by the same server
        # as the master, which can be using either a self signed CA, or an external CA.
        # Zypper has issues with validating a self signed CA, so for now disable ssl verification.
        $repo_settings = {
          'name'        => $repo_name,
          'enabled'     => '1',
          'autorefresh' => '0',
          'baseurl'     => "${source}?ssl_verify=no",
          'type'        => 'rpm-md',
        }

        $repo_settings.each |String $setting, String $value| {
          ini_setting { "zypper ${repo_name} ${setting}":
            ensure  => present,
            path    => $repo_file,
            section => $repo_name,
            setting => $setting,
            value   => $value,
            before  => Exec["refresh-${repo_name}"],
          }
        }

        exec { "refresh-${repo_name}":
          path      => '/bin:/usr/bin:/sbin:/usr/sbin',
          unless    => "zypper search -r ${repo_name} -s | grep puppet-agent | awk '{print \$7}' | grep \"^${agent_version}\"",
          command   => "zypper refresh ${repo_name}",
          logoutput => 'on_failure',
        }
      }
    }
    default: {
      fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
    }
  }
}
