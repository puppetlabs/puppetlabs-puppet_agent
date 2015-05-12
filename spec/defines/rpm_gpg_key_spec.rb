require 'spec_helper'

describe 'agent_upgrade::rpm_gpg_key' do

  let :facts do
    {
      :osfamily         => 'RedHat',
      :operatingsystem  => 'CentOS',
    }
  end
    
  let :title do
    'RPM-GPG-KEY-puppetlabs'
  end
  
  let :params do
    { :path => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs' }
  end

  it do
    should contain_exec('import-RPM-GPG-KEY-puppetlabs').with({
      'path'      => '/bin:/usr/bin:/sbin:/usr/sbin',
      'command'   => 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
      'unless'    => 'rpm -q gpg-pubkey-`echo $(gpg --throw-keyids < /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs) | cut --characters=11-18 | tr [A-Z] [a-z]`',
      'require'   => 'File[/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs]',
      'logoutput' => 'on_failure',
    })
  end
end
