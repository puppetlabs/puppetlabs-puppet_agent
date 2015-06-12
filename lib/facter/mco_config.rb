['server', 'client'].each do |node|
  Facter.add("mco_#{node}_config") do
    setcode do
      config = nil
      if Facter.fact(:kernel).value =~ /windows/i
        config_dir = File.expand_path(File.join(Puppet.settings['confdir'],'../../mcollective/etc'))
        locations = ["#{config_dir}/#{node}.cfg"]
      else
        locations = ["/etc/puppetlabs/mcollective/#{node}.cfg", "/etc/mcollective/#{node}.cfg"]
      end
      locations.each do |cfg|
        if File.exists? cfg
          config = cfg
        end
      end
      config
    end
  end

  Facter.add("mco_#{node}_settings") do
    setcode do
      settings = nil
      config = Facter.fact("mco_#{node}_config".to_sym)
      if config and config.value
        settings = {}

        File.readlines(config.value).select {|v|
          v.lstrip =~ /[^#].+=.+/
        }.map {|x|
          x.split('=', 2).map {|s| s.strip}
        }.select {|k, v|
          k == 'libdir' || k == 'plugin.yaml'
        }.each {|k, v|
          if settings[k]
            settings[k] += ':' + v
          else
            settings[k] = v
          end
        }
      end
      settings
    end
  end
end
