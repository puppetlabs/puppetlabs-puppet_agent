Puppet::Type.newtype(:agent_upgrade) do
  @doc = <<-'EOT'
    Manages the agent_upgrade process and allows for file sources varying from
    HTTP(S), UNC and drive paths such as C:\puppet-agent-x64-latest.msi
  EOT

  ensurable

  newparam(:name, :namevar => true)

  newparam(:source) do
    desc 'Source URL or full path that includes MSI to be passed to msiexec'
    newvalues /^(https?:\/\/)|\\\\\S+\\\w+|[a-z]:\\/i
    validate do |value|
      if value !~ /^((https?|puppet):\/\/)|\\\\\S+\\\w+|[a-z]:\\/i
        fail "Please provide a valid http(s), puppet or unc path"
      end
      if value =~ /^https?/ && value !~ URI::regexp
        fail("Please provide a valid URI")
      end
    end
  end

  newparam(:arch) do
    desc 'Architecture you would like to install'
    newvalues /^(x86|x64)$/
  end

  newproperty(:version) do
    desc 'Puppet Agent version numbers i.e. 1.0.0, defaults to latest'
    defaultto 'latest'
    validate do |value|
      if value !~ /^(latest|\d+\.\d+\.\d+)$/
        fail "Valid values are 'latest' or full version numbers, you provided '#{value}'"
      end
    end
  end
end
