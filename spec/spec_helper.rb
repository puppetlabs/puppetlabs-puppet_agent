require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts


RSpec.configure do |c|
  c.default_facts = {
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
      },
    },
  }
end
