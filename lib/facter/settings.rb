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

Facter.add('puppet_stringify_facts') do
  setcode do
    Puppet.settings['stringify_facts'] || false
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

Facter.add('puppet_master_server') do
  setcode do
    if Puppet.settings['server_list'].nil? || Puppet.settings['server_list'].empty?
      Puppet.settings['server']
    else
      case (entry = Puppet.settings['server_list'].first)
      when Array
        # Tuple of hostname and port
        entry.first
      else
        entry
      end
    end
  end
end

Facter.add('puppet_confdir') do
  setcode do
    Puppet.settings['confdir']
  end
end

Facter.add('puppet_client_datadir') do
  setcode do
    Puppet.settings['client_datadir']
  end
end

Facter.add('mco_confdir') do
  setcode do
    File.expand_path(File.join(Puppet.settings['confdir'],'../../mcollective/etc'))
  end
end
