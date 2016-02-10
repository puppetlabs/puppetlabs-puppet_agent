class puppet_agent::osfamily::suse(
  $package_file_name = undef,
) {
  assert_private()

  if $::operatingsystem != 'SLES' or $::puppet_agent::is_pe == false {
    fail("${::operatingsystem} not supported")
  }

  case $::operatingsystemmajrelease {
    '10': {
      class { 'puppet_agent::prepare::package':
        package_file_name => $package_file_name,
      }
      contain puppet_agent::prepare::package
    }
    '11', '12': {
      # Import the GPG key
      $keyname     = 'RPM-GPG-KEY-puppetlabs'
      $gpg_path    = "/etc/pki/rpm-gpg/${keyname}"
      $gpg_homedir = '/root/.gnupg'

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
        unless    => "rpm -q gpg-pubkey-$(echo $(gpg --homedir ${gpg_homedir} --throw-keyids < ${gpg_path}) | cut --characters=11-18 | tr [A-Z] [a-z])",
        require   => File[$gpg_path],
        logoutput => 'on_failure',
      }


      # Set up a zypper repository by creating a .repo file which mimics a ini file
      $pe_server_version = pe_build_version()
      $source = "${::puppet_agent::source}/${pe_server_version}/${::platform_tag}"

      $repo_file = '/etc/zypp/repos.d/pc1_repo.repo'
      $repo_name = 'pc1_repo'

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
        }
      }
    }
    default: {
      fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
    }
  }
}
