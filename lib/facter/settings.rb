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

Facter.add('puppet_sslpaths') do
  setcode do
    result = {}
    settings = ['privatedir', 'privatekeydir', 'publickeydir', 'certdir', 'requestdir', 'hostcrl']
    settings.each do |setting|
      path = Puppet.settings[setting]
      exists = File.exist? path
      result[setting] = {
        'path'    => path,
        'path_exists'  => exists,
      }
    end
    result
  end
end
