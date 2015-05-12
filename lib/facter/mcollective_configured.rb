Facter.add('mcollective_configured') do
  setcode do
    File.exists? '/etc/mcollective/server.cfg'
  end
end
