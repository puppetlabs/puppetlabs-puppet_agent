Facter.add(:puppet_agent_pid) do
  setcode { Process.pid }
end
