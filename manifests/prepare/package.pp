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
  $package_file_name,
) {
  assert_private()

  # As it is currently written, this will only work if the `pe_build_version()` function
  # is available.
  if getvar('puppet_agent::is_pe') == true {
    $pe_server_version = pe_build_version()

    if $::osfamily == 'windows' {
      $tag = $::puppet_agent::arch ? {
        'x64' => 'windows-x86_64',
        'x86' => 'windows-i386',
      }
      $source = "puppet:///pe_packages/${pe_server_version}/${tag}/${package_file_name}"
    } elsif $::operatingsystem == 'AIX' {
      if $::puppet_agent::collection =~ /(PC1|puppet5)/ {
        $tag = $::platform_tag ? {
          'aix-7.2-power' => 'aix-7.1-power',
          default         => $::platform_tag,
        }
      } else {
        # From puppet6 onward, AIX 6.1 packages are used for all AIX platforms
        $tag = 'aix-6.1-power'
      }

      $source = "puppet:///pe_packages/${pe_server_version}/${tag}/${package_file_name}"
    } else {
      $source = "puppet:///pe_packages/${pe_server_version}/${::platform_tag}/${package_file_name}"
    }

    file { $::puppet_agent::params::local_packages_dir:
      ensure => directory,
    }

    if $::osfamily =~ /windows/ {
      $local_package_file_path = windows_native_path("${::puppet_agent::params::local_packages_dir}/${package_file_name}")
      $mode = undef
    } else {
      $local_package_file_path = "${::puppet_agent::params::local_packages_dir}/${package_file_name}"
      $mode = '0644'
    }

    # When running against a puppet 3 agent, we want to use the
    # default checksum method, due to old bugs when specifying custom
    # checksums. For puppet 4, we can use sha256lite and avoid some
    # extra processing time.
    $checksum = $::aio_agent_version ? {
      undef   => undef,
      default => sha256lite,
    }

    file { $local_package_file_path:
      ensure   => present,
      owner    => $::puppet_agent::params::user,
      group    => $::puppet_agent::params::group,
      mode     => $mode,
      source   => $source,
      require  => File[$::puppet_agent::params::local_packages_dir],
      checksum => $checksum
    }
  }
}
