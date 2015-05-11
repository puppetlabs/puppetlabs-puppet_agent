require 'puppet'

Facter.add('puppet_ssldir') do
  setcode do
    Puppet.settings['ssldir']
  end
end

Facter.add('puppet_config') do
  setcode do
    Puppet.settings['config']
  end
end
