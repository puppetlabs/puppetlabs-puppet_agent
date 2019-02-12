# == Class puppet_agent::prepare::package
#
# The only job this class has is to ensure that the correct puppet-agent
# package is downloaded locally for installation.  This is used on platforms
# without package managers capable of working with a remote https repository.
#
# [package_file_name]
#   The puppet-agent package file to retrieve from the master.
#
class puppet_agent::prepare::package(
  $source,
){
  assert_private()

  file { $::puppet_agent::params::local_packages_dir:
    ensure => directory,
  }

  $package_file_name = basename($source)
  if $::osfamily =~ /windows/ {
    $local_package_file_path = windows_native_path("${::puppet_agent::params::local_packages_dir}/${package_file_name}")
    $mode = undef
  } else {
    $local_package_file_path = "${::puppet_agent::params::local_packages_dir}/${package_file_name}"
    $mode = '0644'
  }

  file { $local_package_file_path:
    ensure   => present,
    owner    => $::puppet_agent::params::user,
    group    => $::puppet_agent::params::group,
    mode     => $mode,
    source   => $source,
    require  => File[$::puppet_agent::params::local_packages_dir],
    checksum => sha256lite
  }
}
