# == Class: puppet_agent
#
# Upgrades Puppet 4 and newer to the requested version.
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
#   The package version to upgrade to. Explicitly specify a version to upgrade
# [service_names]
#   An array of services to start, normally `puppet` and `mcollective`.
#   None will be started if the array is empty.
# [source]
#   **INCLUDED FOR COMPATIBILITY WITH MODULE VERSIONS 1.0/2.0. PREFER USE OF "absolute_source",
#   "apt_source", "deb_source" etc. OVER USE OF "source".**
#
#   The location to find packages. Replaces base URL for unix/MacOS agents, used as fully
#   qualified path in windows
# [absolute_source]
#   The exact location of the package to install. The entire path to the package must be
#   provided with this parameter.
# [yum_source]
#   Base URL of the location of mirrors of yum.puppet.com downloads sites. Directories under
#   the URL "yum_source" should match the structure of the yum.puppet.com
# [apt_source]
#   Base URL of the location of mirrors of apt.puppet.com downloads sites. Directories under
#   the URL "apt_source" should match the structure of the apt.puppet.com
# [mac_source]
#   Base URL of the location of mirrors of downloads.puppet.com downloads site that serves
#   MacOS packages. Directories under the URL "mac_source" should match the structure of the
#   downloads.puppet.com site
# [windows_source]
#   Base URL of the location of mirrors of downloads.puppet.com downloads site that serves
#   Windows packages. Directories under the URL "windows_source" should match the structure of
#   the downloads.puppet.com site
# [solaris_source]
#   Base URL of the location of a mirror for Solaris packages. Currently, solaris packages can
#   only be made available by using puppetlabs-pe_repo. This means the mirror must be of a
#   PE master package serve.
# [aix_source]
#   Base URL of the location of a mirror for AIX packages. Currently, AIX packages can
#   only be made available by using puppetlabs-pe_repo. This means the mirror must be of a
#   PE master package serve.
# [use_alternate_sources]
#   **ONLY APPLICABLE WHEN WORKING WITH PE INSTALLTIONS**
#   When set to true will force downloads to come from the values of $apt_source, $deb_source
#   $mac_source etc. rather than from the default PE master package serve. Note that this will
#   also force downloads to ignore alternate_pe_source
# [alternate_pe_source]
#   Base URL of the location where packages are located in the same structure that's served
#   by a PE master (the directory structure in PE for serving packages is created by the
#   puppetlabs-pe_repo module). The general structure served by PE is:
#   /packages/${pe_server_version}/${platform_tag}/${package_name}
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
  $arch                    = $::architecture,
  $collection              = $::puppet_agent::params::collection,
  $is_pe                   = $::puppet_agent::params::_is_pe,
  $manage_pki_dir          = true,
  $manage_repo             = true,
  $package_name            = 'puppet-agent',
  $package_version         = undef,
  $service_names           = $::puppet_agent::params::service_names,
  $source                  = undef,
  $absolute_source         = undef,
  $yum_source              = 'http://yum.puppet.com',
  $apt_source              = 'https://apt.puppet.com',
  $mac_source              = 'https://downloads.puppet.com',
  $windows_source          = 'https://downloads.puppet.com',
  $solaris_source          = 'puppet:///pe_packages',
  $aix_source              = 'puppet:///pe_packages',
  $use_alternate_sources   = false,
  $alternate_pe_source     = undef,
  $install_dir             = undef,
  $disable_proxy           = false,
  $install_options         = [],
  $skip_if_unavailable     = 'absent',
  $msi_move_locked_files   = false,
) inherits ::puppet_agent::params {

  if (getvar('::aio_agent_version') == undef) {
    fail('The puppet_agent module does not support pre-Puppet 4 upgrades.')
  }

  if $source != undef and $absolute_source != undef {
    fail('Only one of $source and $absolute_source can be set')
  }

  if $::osfamily == 'windows' and $install_dir != undef {
    validate_absolute_path($install_dir)
  }

  if $package_version == undef {
    info('puppet_agent performs no actions if a package_version is not specified')
  } elsif defined('$::pe_server_version') {
    info('puppet_agent performs no actions on PE infrastructure nodes to prevent a mismatch between agent and PE components')
  } else {
    # In this code-path, $package_version != undef AND we are not on a PE infrastructure
    # node since $::pe_server_version is not defined

    if $package_version !~ /^\d+\.\d+\.\d+([.-]?\d*|\.\d+\.g[0-9a-f]+)$/ {
      fail("invalid version ${package_version} requested")
    }

    # Strip git sha from dev builds
    if $package_version =~ /g/ {
      $_expected_package_version = split($package_version, /[.-]g.*/)[0]
    } else {
      $_expected_package_version = $package_version
    }

    $aio_upgrade_required = versioncmp("${::aio_agent_version}", "${_expected_package_version}") < 0

    if $::architecture == 'x86' and $arch == 'x64' {
      fail('Unable to install x64 on a x86 system')
    }

    if $::operatingsystem == 'Solaris' and $::operatingsystemmajrelease == '11' {
      # Strip letters from development builds. Unique to Solaris 11 packaging.
      $_version_without_letters = regsubst($::puppet_agent::package_version, '[a-zA-Z]', '', 'G')
      $_version_without_orphan_dashes = regsubst($_version_without_letters, '(^-|-$)', '', 'G')
      $_package_version = regsubst($_version_without_orphan_dashes, '\b(?:0*?)([1-9]\d*|0)\b', '\1', 'G')
    } else {
      $_package_version = $package_version
    }

    class { '::puppet_agent::prepare':
      package_version => $_package_version,
    }
    -> class { '::puppet_agent::install':
      package_version => $_package_version,
      install_dir     => $install_dir,
      install_options => $install_options,
    }

    contain '::puppet_agent::prepare'
    contain '::puppet_agent::install'

    # Service management:
    # - Under Puppet Enterprise, the agent nodegroup is managed by PE, and we don't need to manage services here.
    # - On Windows, services are handled by the puppet-agent MSI packages themselves.
    # ...but outside of PE, on other platforms, we must make sure the services are restarted. We do that with the
    # ::puppet_agent::service class. Make sure it's applied after the install process finishes if needed:
    if $::osfamily != 'windows' and (!$is_pe or versioncmp($::clientversion, '4.0.0') < 0) {
      class { '::puppet_agent::service':
        require => Class['::puppet_agent::install'],
      }
      contain '::puppet_agent::service'
    }
  }
}
