require 'tmpdir'

Facter.add(:env_temp_variable) do
  setcode {
    tmp = ENV['TEMP'] || Dir.tmpdir
    tmp.gsub!(/\\\s/, " ") # Remove space escapses in unix just in case
    tmp.gsub!(/\//, '\\')
  }
end
