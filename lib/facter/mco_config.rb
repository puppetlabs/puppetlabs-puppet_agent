['server', 'client'].each do |node|
  Facter.add("mco_#{node}_config") do
    setcode do
      config = nil
      if %r{windows}i.match?(Facter.fact(:kernel).value)
        config_dir = File.expand_path(File.join(Puppet.settings['confdir'], '../../mcollective/etc'))
        locations = ["#{config_dir}/#{node}.cfg"]
      else
        locations = ["/etc/puppetlabs/mcollective/#{node}.cfg", "/etc/mcollective/#{node}.cfg"]
      end
      locations.each do |cfg|
        if File.exist? cfg
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
      if config&.value
        settings = {}

        File.readlines(config.value).select { |v| v.lstrip =~ %r{[^#].+=.+} }
            .map { |x| x.split('=', 2).map { |s| s.strip } }
            .select { |k, _v| ['libdir', 'plugin.yaml'].include?(k) }
            .each do |k, v|
          if settings[k]
            settings[k] += ':' + v
          else
            settings[k] = v
          end
        end
      end
      settings
    end
  end
end
