Facter.add(:puppet_agent_appdata) do
  setcode do
    if Dir.const_defined? 'COMMON_APPDATA'
      Dir::COMMON_APPDATA.gsub(%r{\\\s}, ' ').tr('/', '\\')
    elsif !ENV['ProgramData'].nil?
      ENV['ProgramData'].gsub(%r{\\\s}, ' ').tr('/', '\\')
    end
  end
end
