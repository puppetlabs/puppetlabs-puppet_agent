['server', 'client'].each do |node|
  Facter.add("mco_#{node}_config") do
    setcode do
      config = nil
      ["/etc/puppetlabs/mcollective/#{node}.cfg", "/etc/mcollective/#{node}.cfg"].each do |cfg|
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
        settings = Hash[File.readlines(config.value).select {|v|
          v.lstrip =~ /[^#].+=.+/
        }.map {|x|
          x.split('=', 2).map {|s| s.strip}
        }.select {|k, v|
          k == 'libdir' || k == 'plugin.yaml'
        }]
      end
      settings
    end
  end
end
