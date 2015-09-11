# == Class: puppet_agent
#
# Upgrades Puppet 3.8 and newer to the requested version.
# Makes Puppet 4 upgrades easier by migrating SSL certs and config files to the
# new Puppet-Agent paths and removing deprecated settings that are no longer
# supported by Puppet 4.
#
# === Parameters
#
# [version]
#   The package version to upgrade to. Defaults to undef, meaning only upgrade from Puppet < 4.0.
# [arch]
#   The package architecture. Defaults to the architecture fact.
# [collection]
#   The Puppet Collection to track. Defaults to 'PC1'.
# [is_pe]
#   Install from Puppet Enterprise repos. Enabled if communicating with a PE master.
# [package_name]
#   The package to upgrade to, i.e. `puppet-agent`.
# [service_names]
#   An array of services to start, normally `puppet` and `mcollective`.
#   None will be started if the array is empty.
# [source]
#   The location to find packages.
#
class puppet_agent (
  $version       = $::puppet_agent::params::version,
  $collection    = $::puppet_agent::params::collection,
  $arch          = $::architecture,
  $is_pe         = $::puppet_agent::params::_is_pe,
  $package_name  = $::puppet_agent::params::package_name,
  $service_names = $::puppet_agent::params::service_names,
  $source        = $::puppet_agent::params::_source,
) inherits ::puppet_agent::params {

  validate_re($arch, ['^x86$','^x64$','^i386$','^amd64$','^x86_64$','^power$'])

  if versioncmp("${::clientversion}", '3.8.0') < 0 {
    fail('upgrading requires Puppet 3.8')
  }
  elsif $::architecture == 'x86' and $arch == 'x64' {
    fail('unable to install x64 on a x86 system')
  }
  elsif $version != undef and $version !~ /^\d+\.\d+\.\d+$/ {
    fail("invalid version ${version} requested")
  }
  else {
    class { '::puppet_agent::prepare': } ->
    class { '::puppet_agent::install':
      version => $version,
    }
    contain '::puppet_agent::prepare'
    contain '::puppet_agent::install'

    if !$::puppet_agent::params::_windows_client {
      # Starting services doesn't work with Windows, as the install must
      # happen after Puppet has completed its run.
      class { '::puppet_agent::service':
        require => Class['::puppet_agent::install']
      }
      contain '::puppet_agent::service'
    }
  }
}
