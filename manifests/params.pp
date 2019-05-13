# == Class puppet_agent::params
#
# This class is meant to be called from puppet_agent
# It sets variables according to platform.
#
class puppet_agent::params {
  # Which services should be started after the upgrade process?
  if ($::osfamily == 'Solaris' and $::operatingsystemmajrelease == '11') {
    # Solaris 11 is a special case; it uses a custom script.
    $service_names = []
  } else {
    # Mcollective will be removed from this list in the service manifest if
    # the puppet version is > 6.0.0
    $service_names = ['puppet', 'mcollective']
  }
  if $::osfamily == 'windows' {
    $local_puppet_dir = windows_native_path("${::puppet_agent_appdata}/Puppetlabs")
    $local_packages_dir = windows_native_path("${local_puppet_dir}/packages")

    $confdir = $::puppet_confdir

    $puppetdirs = [regsubst($confdir,'\/etc\/','/code/')]
    $path_separator = ';'

    $user  = 'S-1-5-32-544'
    $group = 'S-1-5-32-544'
  } else {
    $local_puppet_dir = '/opt/puppetlabs'
    $local_packages_dir = "${local_puppet_dir}/packages"

    $confdir = '/etc/puppetlabs/puppet'

    # A list of dirs that need to be created. Mainly done this way because
    # Windows requires more directories to exist for confdir.
    $puppetdirs = ['/etc/puppetlabs', $confdir]

    $path_separator = ':'

    $user  = 0
    $group = 0
  }
  $ssldir = "${confdir}/ssl"
  $config = "${confdir}/puppet.conf"

  # The `is_pe` fact currently works by echoing out the puppet version
  # and greping for "puppet enterprise". With Puppet 4 and PE 2015.2, there
  # is no longer a "PE Puppet", and so that fact will no longer work.
  # Instead check for the `is_pe` fact or if a PE provided function is available
  $_is_pe = (getvar('::is_pe') or is_function_available('pe_compiling_server_version'))
  if $_is_pe {
    # Calculate the default collection
    $_pe_version = pe_build_version()
    # Not PE or pe_version < 2018.1.3, use PC1
    if ($_pe_version == undef or versioncmp("${_pe_version}", '2018.1.3') < 0) {
      $collection = 'PC1'
    }
    # 2018.1.3 <= pe_version < 2018.2, use puppet5
    elsif versioncmp("${_pe_version}", '2018.2') < 0 {
      $collection = 'puppet5'
    }
    # pe_version >= 2018.2, use puppet6
    else {
      $collection = 'puppet6'
    }
    # The aio puppet-agent version currently installed on the compiling master
    # (only used in PE)
    if is_function_available('pe_compiling_server_aio_build') {
      $master_agent_version = pe_compiling_server_aio_build()
    } else {
      $master_agent_version = undef
    }
  } else {
    $_pe_version = undef
    $pe_repo_dir = undef
    $master_agent_version = undef
    $collection = 'PC1'
  }
}
