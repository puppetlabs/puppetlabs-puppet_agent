# == Class puppet_agent::prepare::package
#
# The only job this class has is to ensure that the correct puppet-agent
# package is downloaded locally for installation.  This is used on platforms
# without package managers capable of working with a remote https repository.
#
# === Parameters
#
# [package_file_name]
#   The puppet-agent package file name to download.
# [package_version]
#   The puppet-agent version to install.
# [source]
#   The location to find packages.
#
class puppet_agent::prepare::package(
  $package_file_name,
  $package_version    = undef,
  $source             = undef,
) {
  assert_private()

  file { $::puppet_agent::params::local_packages_dir:
    ensure => directory,
  }

  # When running against a Puppet 3.x agent use the default checksum method,
  # due to old bugs when specifying custom checksums. 
  # For Puppet 4+, use sha256lite and avoid extra processing time.
  $checksum = $::aio_agent_version ? {
    undef   => undef,
    default => sha256lite,
  }

  if getvar('puppet_agent::is_pe') == true and $::osfamily != 'windows' {
    $pe_server_version = pe_build_version()
    if $::osfamily == 'AIX' {
      $tag = $::platform_tag ? {
        'aix-7.2-power' => 'aix-7.1-power',
        default         => $::platform_tag,
      }
      $_source = "${::puppet_agent::params::pe_repo_puppet}/${pe_server_version}/${tag}/${package_file_name}"
    } else {
      $_source = "${::puppet_agent::params::pe_repo_puppet}/${pe_server_version}/${::platform_tag}/${package_file_name}"
    }
    $_staged = "${::puppet_agent::params::local_packages_dir}/${package_file_name}"
    file { $_staged:
      ensure   => present,
      owner    => $::puppet_agent::params::user,
      group    => $::puppet_agent::params::group,
      mode     => '0644',
      source   => $_source,
      require  => File[$::puppet_agent::params::local_packages_dir],
      checksum => $checksum
    }
  }

  # Whether or not is_pe, download remote packages on Windows ...
  if $::osfamily == 'windows' {
    if getvar('puppet_agent::is_pe') == true and $source == undef {
      $pe_server_version = pe_build_version()
      $tag = $::puppet_agent::arch ? {
        'x86'   => 'windows-i386',
        default => 'windows-x86_64',
      }
      # On the master, the package version is in the directory name rather than the file name.
      $pe_repo_package_file_name = delete($package_file_name, "-${package_version}")
      # Use pe_repo_puppet to avoid file source https self-signed certificate errors with pe_repo.
      $_source = "${::puppet_agent::params::pe_repo_puppet}/${pe_server_version}/${tag}-${package_version}/${pe_repo_package_file_name}"
      $_staged = windows_native_path("${::puppet_agent::params::local_packages_dir}/${package_file_name}")
    } else {
      # The source may be a prefix or a fully-qualified file.
      if $source and $source =~ /(.*)[\/\\](.*?\.msi)$/ {
        $prefix = $1
        $file = $2
      } else {
        $prefix = $source
        $file = $package_file_name
      }
      $_source = $source ? {
        undef        => "${::puppet_agent::params::packages_https}/windows/${package_file_name}",
        /^[a-zA-Z]:/ => windows_native_path("${prefix}/${file}"),
        /^\\\\./     => windows_native_path("${prefix}/${file}"),
        default      => "${prefix}/${file}",
      }
      $_staged = windows_native_path("${::puppet_agent::params::local_packages_dir}/${file}")
    }
    if versioncmp("${::clientversion}", '4.4.0') == -1 and $_source =~ /^https?:/ {
      # Use --insecure to ignore self-signed certificate errors.
      exec { 'download_puppet-agent.msi':
        command => "curl --fail --silent --show-error --output ${_staged} --url ${_source}",
        creates => $_staged,
        path    => $::path,
        require => File[$::puppet_agent::params::local_packages_dir],
      }
    } else {
      file { 'download_puppet-agent.msi':
        ensure   => present,
        path     => $_staged,
        owner    => $::puppet_agent::params::user,
        group    => $::puppet_agent::params::group,
        source   => $_source,
        require  => File[$::puppet_agent::params::local_packages_dir],
        checksum => $checksum
      }
    }
  }

}