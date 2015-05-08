require 'puppet'
Facter.add('settings') do
  setcode do
    result = {}
    Puppet.settings.each { |k, v|
      Puppet.info "#{k} = #{v.value}"
      result[k.to_s] = v.value.to_s
    }
    result
  end
end
