require 'tmpdir'

Facter.add(:env_temp_variable) do
  setcode do
    (ENV['TEMP'] || Dir.tmpdir)
  end
end
