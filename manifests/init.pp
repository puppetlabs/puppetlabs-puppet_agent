# == Class: puppet_agent
#
# Upgrades Puppet 3.8 and newer to the requested version.
# Makes Puppet 4 upgrades easier by migrating SSL certs and config files to the
# new Puppet-Agent paths and removing deprecated settings that are no longer
# supported by Puppet 4.
#
# === Parameters
#
# [arch]
#   The package architecture. Defaults to the architecture fact.
# [collection]
#   The Puppet Collection to track. Defaults to 'PC1'.
# [is_pe]
#   Install from Puppet Enterprise repos. Enabled if communicating with a PE master.
# [manage_pki_dir]
#   Whether or not to manage the /etc/pki directory.  Defaults to true.
#   Managing the /etc/pki directory inside the puppet_agent module can be problematic for
#   organizations that manage gpg keys and settings in other modules.
# [manage_repo]
#   Boolean to determine whether to configure repositories
#   This is intended to provide the ability to disable configuring a local repo
#   in support of systems that manage external repositories (i.e. spacewalk/satellite)
#   to enable users to add the proper packages to their internal repos
#   and to utilize default package providers for the install
# [package_name]
#   The package to upgrade to, i.e. `puppet-agent`.
# [package_version]
#   The package version to upgrade to. When upgrading from Puppet < 4.0, defaults to
#   the puppet master's latest supported version if compiled with a PE master or
#   undef otherwise (meaning get the latest Open Source release). Explicitly specify
#   a version to upgrade from puppet-agent packages (implying Puppet >= 4.0).
# [service_names]
#   An array of services to start, normally `puppet` and `mcollective`.
#   None will be started if the array is empty.
# [source]
#   The location to find packages.
# [install_dir]
#   The directory the puppet agent should be installed to. This is only applicable for
#   windows operating systems. This only applies when upgrading the agent to a new
#   version; it will not cause re-installation of the same version to a new location.
# [install_options]
#   An array of additional options to pass when installing puppet-agent. Each option in
#   the array can either be a string or a hash. Each option will automatically be quoted
#   when passed to the install command. With Windows packages, note that file paths in an
#   install option must use backslashes. (Since install options are passed directly to
#   the installation command, forward slashes won't be automatically converted like they
#   are in `file` resources.) Note also that backslashes in double-quoted strings _must_
#   be escaped and backslashes in single-quoted strings _can_ be escaped.
# [msi_move_locked_files]
#   This is only applicable for Windows operating systems. There may be instances where
#   file locks cause unncessary service restarts.  By setting to true, the module
#   will move files prior to installation that are known to cause file locks.
#
class puppet_agent (
  $arch                  = $::architecture,
  $collection            = $::puppet_agent::params::collection,
  $is_pe                 = $::puppet_agent::params::_is_pe,
  $manage_pki_dir        = true,
  $manage_repo           = true,
  $package_name          = $::puppet_agent::params::package_name,
  $package_version       = $::puppet_agent::params::package_version,
  $service_names         = $::puppet_agent::params::service_names,
  $source                = $::puppet_agent::params::_source,
  $install_dir           = $::puppet_agent::params::install_dir,
  $disable_proxy         = false,
  $install_options       = $::puppet_agent::params::install_options,
  $skip_if_unavailable   = 'absent',
  $msi_move_locked_files = false,
) inherits ::puppet_agent::params {

  validate_re($arch, ['^x86$','^x64$','^i386$','^i86pc$','^amd64$','^x86_64$','^power$','^sun4[uv]$', '^ppc64le$', '^aarch64$', 'PowerPC_POWER'])

  if $::osfamily == 'windows' and $install_dir != undef {
    validate_absolute_path($install_dir)
  }

  if $package_version == undef and versioncmp("${::clientversion}", '4.0.0') >= 0 {
    info('puppet_agent performs no actions if a package_version is not specified on Puppet 4')
  } elsif $package_version == undef and $is_pe {
    info("puppet_agent performs no actions if the master's agent version cannot be determed on PE 3.x")
  } elsif defined('$::pe_server_version') {
    info('puppet_agent performs no actions on PE infrastructure nodes to prevent a mismatch between agent and PE components')
  } else {
    if $package_version != undef and $package_version !~ /^\d+\.\d+\.\d+([.-]?\d*|\.\d+\.g[0-9a-f]+)$/ {
      fail("invalid version ${package_version} requested")
    }

    # Strip git sha from dev builds
    if ($package_version != undef and $package_version =~ /g/){
      $_expected_package_version = split($package_version, /[.-]g.*/)[0]
    } else {
      $_expected_package_version = $package_version
    }

    $aio_upgrade_required = ($is_pe == false and $_expected_package_version != undef) or
      (getvar('::aio_agent_version') != undef and $_expected_package_version != undef and
        versioncmp("${::aio_agent_version}", "${_expected_package_version}") < 0)

    if $::architecture == 'x86' and $arch == 'x64' {
      fail('Unable to install x64 on a x86 system')
    }

    # Allow for normalizing package_version for the package provider via _package_version.
    # This only needs to be passed through to install, as elsewhere we want to
    # use the full version string for comparisons.
    if $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '11' {
      # Strip letters from development builds. Unique to Solaris 11 packaging.
      # Need to pass the regex as strings for Puppet 3 compatibility.
      $_version_without_letters = regsubst($package_version, '[a-zA-Z]', '', 'G')
      $_version_without_orphan_dashes = regsubst($_version_without_letters, '(^-|-$)', '', 'G')
      $_package_version = regsubst($_version_without_orphan_dashes, '\b(?:0*?)([1-9]\d*|0)\b', '\1', 'G')
    } else {
      $_package_version = $package_version
    }

    if $::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '10' {
      $_package_file_name = "${puppet_agent::package_name}-${package_version}-1.sles10.${::architecture}.rpm"
    } elsif $::operatingsystem == 'Solaris' {
      $pkg_arch = $arch ? {
        /^sun4[uv]$/ => 'sparc',
        default      => 'i386',
      }

      if $::operatingsystemmajrelease == '10' {
        $_package_file_name = "${puppet_agent::package_name}-${package_version}-1.${pkg_arch}.pkg.gz"
      } elsif $::operatingsystemmajrelease == '11' {
        $_package_file_name = "${puppet_agent::package_name}@${_package_version},5.11-1.${pkg_arch}.p5p"
      }
    } elsif $::operatingsystem == 'Darwin' and $::macosx_productversion_major =~ /^10\.(9|10|11|12|13)/ {
      $_package_file_name = "${puppet_agent::package_name}-${package_version}-1.osx${$::macosx_productversion_major}.dmg"
    } elsif $::operatingsystem == 'AIX' {
      $_aix_ver_number = regsubst($::platform_tag,'aix-(\d+\.\d+)-power','\1')
      if $_aix_ver_number {
        if $collection =~ /(PC1|puppet5)/ {
          $aix_ver_number = $_aix_ver_number ? {
            /^7\.2$/ => '7.1',
            default  => $_aix_ver_number,
          }
        } else {
          $aix_ver_number = '6.1'
        }
      }
      $_package_file_name = "${puppet_agent::package_name}-${package_version}-1.aix${aix_ver_number}.ppc.rpm"
    } elsif $::osfamily == 'windows' {
      $_arch = $::kernelmajversion ?{
        /^5\.\d+/ => 'x86', # x64 is never allowed on windows 2003
        default   => $arch
      }

      if $is_pe {
        $_package_file_name = "${package_name}-${_arch}.msi"
      } elsif $package_version != undef {
        $_package_file_name = "${package_name}-${package_version}-${_arch}.msi"
      } else {
        $_package_file_name = "${package_name}-${_arch}-latest.msi"
      }
    } else {
      $_package_file_name = undef
    }

    class { '::puppet_agent::prepare':
      package_file_name => $_package_file_name,
      package_version   => $package_version,
    }
    -> class { '::puppet_agent::install':
      package_file_name => $_package_file_name,
      package_version   => $_package_version,
      install_dir       => $install_dir,
      install_options   => $install_options,
    }

    contain '::puppet_agent::prepare'
    contain '::puppet_agent::install'

    # On windows, our MSI handles the services
    # On PE AIO nodes, PE Agent nodegroup is managing the services
    if $::osfamily != 'windows' and (!$is_pe or versioncmp($::clientversion, '4.0.0') < 0) {
      class { '::puppet_agent::service':
        require => Class['::puppet_agent::install'],
      }
      contain '::puppet_agent::service'
    }

  }
}
