require 'spec_helper'

describe 'puppet_agent::osfamily::debian' do
  let(:facts) {{
    :lsbdistid => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :operatingsystem => 'Debian',
    :architecture => 'foo',
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
