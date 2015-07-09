# == Class puppet_agent::prepare::ssl
#
# Private class called from puppet_agent::prepare class
#
# All SSL reconfigure changes should be done within this class
#
class puppet_agent::prepare::ssl {
  assert_private()

  $ssl_dir = $::puppet_agent::params::ssldir
  file { $ssl_dir:
    ensure  => directory,
    source  => $::puppet_ssldir,
    backup  => false,
    recurse => false,
  }

  $sslpaths = {
    'certdir'       => 'certs',
    'privatedir'    => 'private',
    'privatekeydir' => 'private_keys',
    'publickeydir'  => 'public_keys',
    'requestdir'    => 'certificate_requests',
  }

  $sslpaths.each |String $setting, String $subdir| {
    if $::puppet_sslpaths[$setting]['path_exists'] {
      file { "${ssl_dir}/${subdir}":
        ensure  => directory,
        source  => $::puppet_sslpaths[$setting]['path'],
        backup  => false,
        recurse => true,
      }
    }
  }

  # The only one that's a file, not a directory.
  if $::puppet_sslpaths['hostcrl']['path_exists'] {
    file { "${ssl_dir}/crl.pem":
      ensure => file,
      source => $::puppet_sslpaths['hostcrl']['path'],
      backup => false
    }
  }
}
