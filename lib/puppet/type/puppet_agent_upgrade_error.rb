Puppet::Type.newtype(:puppet_agent_upgrade_error) do
  @doc = <<-DOC
Fails when a previous background installation failed. The type
will check for the existance of an installation failure log
and raise an error with the contents of the log if it exists
DOC

  newproperty(:ensure_notexist) do
    desc "whether or not the error log exists"
    def insync?(not_exist)
      if not_exist
        true
      else
        raise Puppet::Error.new("Failed previous installation with: #{provider.read_content_and_delete_file(@resource[:name])}")
      end
    end

    defaultto { true }
  end

  newparam(:name) do
    desc "The name of the failure log to check for in puppet's $statedir. If this log exists the resource will fail."
    isnamevar
  end
end
