# @summary Ensures correct puppet-agent package is downloaded locally.
# for installation. This is used on platforms without package managers capable of
# working with a remote https repository.
#
# @param source
#   The source file for the puppet-agent package. Can use any of the data types
#   and protocols that the File resource's source attribute can.
class puppet_agent::prepare::package (
  Variant[String, Array] $source,
) {
  assert_private()

  file { $puppet_agent::params::local_packages_dir:
    ensure => directory,
  }

  # In order for the 'basename' function to work correctly we need to change
  # any \s to /s (even for windows UNC paths) so that it will correctly pull off
  # the filename. Since this operation is only grabbing the base filename and not
  # any part of the path this should be safe, since the source will simply remain
  # what it was before and we can still pull off the filename.
  $package_file_name = basename(regsubst($source, "\\\\", '/', 'G'))
  if $facts['os']['family'] =~ /windows/ {
    $local_package_file_path = windows_native_path("${puppet_agent::params::local_packages_dir}/${package_file_name}")
    $mode = undef
  } else {
    $local_package_file_path = "${puppet_agent::params::local_packages_dir}/${package_file_name}"
    $mode = '0644'
  }

  file { $local_package_file_path:
    ensure  => file,
    owner   => $puppet_agent::params::user,
    group   => $puppet_agent::params::group,
    mode    => $mode,
    source  => $source,
    require => File[$puppet_agent::params::local_packages_dir],
  }
}
