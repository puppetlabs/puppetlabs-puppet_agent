Facter.add(:puppet_runmode) do
  setcode { Puppet.run_mode.name.to_s }
end
