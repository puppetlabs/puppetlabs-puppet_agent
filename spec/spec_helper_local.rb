require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.default_facts = {
    :aio_agent_version           => '1.10.100',
    :puppetversion               => nil,
    :lsbdistrelease              => nil,
    :is_pe                       => false,
    :platform_tag                => nil,
    :operatingsystem             => nil,
    :operatingsystemmajrelease   => nil,
    :kernelmajversion            => nil,
    :macosx_productname          => nil,
    :maxosx_productversion_major => nil,
    :rubyplatform                => nil,
    :puppet_master_server        => nil,
    :puppet_client_datadir       => nil,
    :path                        => nil,
    :puppet_agent_appdata        => nil,
    :system32                    => nil,

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
