Facter.add(:puppet_agent_appdata) do
  setcode do
    if Dir.const_defined? 'COMMON_APPDATA' then
      Dir::COMMON_APPDATA.gsub(/\\\s/, " ").gsub(/\//, '\\')
    elsif not ENV['ProgramData'].nil?
      ENV['ProgramData'].gsub(/\\\s/, " ").gsub(/\//, '\\')
    end
  end
end
