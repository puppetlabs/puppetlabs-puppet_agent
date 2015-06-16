require 'spec_helper'

describe 'puppet_agent', :unless => Puppet.version < "3.8.0" || Puppet.version >= "4.0.0" do
  let(:facts) {{
    :lsbdistid => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :operatingsystem => 'Debian',
    :architecture => 'x64',
    :puppet_ssldir   => '/dev/null/ssl',
    :puppet_config   => '/dev/null/puppet.conf',
    :puppet_sslpaths => {
      'privatedir'    => {
        'path'   => '/dev/null/ssl/private',
        'path_exists' => true,
      },
      'privatekeydir' => {
        'path'   => '/dev/null/ssl/private_keys',
        'path_exists' => true,
      },
      'publickeydir'  => {
        'path'   => '/dev/null/ssl/public_keys',
        'path_exists' => true,
      },
      'certdir'       => {
        'path'   => '/dev/null/ssl/certs',
        'path_exists' => true,
      },
      'requestdir'    => {
        'path'   => '/dev/null/ssl/certificate_requests',
        'path_exists' => true,
      },
      'hostcrl'       => {
        'path'   => '/dev/null/ssl/crl.pem',
        'path_exists' => true,
      },}
  }}

  it { is_expected.to contain_class('apt') }

  it { is_expected.to contain_apt__source('pc1_repo').with({
    'location' => 'http://apt.puppetlabs.com',
    'repos'    => 'PC1',
    'key'      => {
      'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      'server' => 'pgp.mit.edu',
    },
  }) }
end
