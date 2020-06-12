require 'puppet/property/boolean'

Puppet::Type.newtype(:puppet_agent_end_run) do
  @doc = <<-DOC
Stops the current Puppet run if a puppet-agent upgrade was
performed. Used on platforms that manage the Puppet Agent upgrade with
a package resource, as resources evaluated after an upgrade might
cause unexpected behavior due to a mix of old and new Ruby code being
loaded in memory.

Platforms that shell out to external scripts for upgrading (Windows,
macOS, and Solaris 10) do not need to use this type.
DOC

  newproperty(:end_run, :boolean => true, parent: Puppet::Property::Boolean) do
    desc "Stops the current puppet run"

    def insync?(is)
      provider.stop
      true
    end

    defaultto { true }
  end

  newparam(:name) do
    desc "The desired puppet-agent version"
    isnamevar
  end
end
