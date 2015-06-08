Puppet::Type.type(:agent_upgrade).provide(:agent_upgrade) do

  @doc = <<-EOT
    Windows provider to upgrade from 3.8 to 4.0 using latest puppet-agent version,
    requires PowerShell to be already installed, only upgrade if < 4.0
  EOT
  confine :osfamily => 'windows'

  mk_resource_methods

  commands :powershell =>
             if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
               "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
             elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
               "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
             else
               'powershell.exe'
             end

  def self.instances
    [new({
           :name => 'puppet-agent',
           :ensure => :present,
           :version => Facter.value(:puppetversion),
         })
    ]
  end

  def create
    spawn_upgrade_process
  end

  def exists?
    false
  end

  def source_location
    resource[:source] ||
      "https://downloads.puppetlabs.com/windows/#{puppet_agent_msi_filename}"
  end

  def puppet_agent_msi_filename
    arch = resource[:arch] || Facter.value(:architecture)
    if resource[:version] =~ /latest/i
      return "puppet-agent-#{arch}-latest.msi"
    end

    "puppet-agent-#{resource[:version]}-#{arch}.msi"
  end


  def get_command
    tempfile = new_logfile_path
    debug "Spawning installer with log at '#{tempfile}'"
    "cmd.exe /c \"\"#{native_path(command(:powershell))}\"" +
      " -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -Command " +
      "\"Wait-Process #{Process.pid} -ErrorAction SilentlyContinue;msiexec /qn /i #{source_location} /l*v #{tempfile} \""
  end

  def new_logfile_path
    native_path(Tempfile.new(['puppet-agent-installer', '.log']).path)
  end

  def spawn_upgrade_process
    args = {
      :command_line => get_command,
      :creation_flags => Process::DETACHED_PROCESS,
      :process_inherit => false,
      :thread_inherit => true,
      :cwd => native_path(Dir.tmpdir),
    }

    debug "Creating wait process for #{Process.pid}"
    upgradeProcess = Process.create(args)
    debug ("Created background process to wait for puppet exit at PID #{upgradeProcess.process_id}")
  end

  def native_path(path)
    path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  end

  def version=(version)
    @property_hash[:version] = version

      self.create
    self.version
  end
end
