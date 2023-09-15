Puppet::Type.type(:puppet_agent_upgrade_error).provide :puppet_agent_upgrade_error do
  desc <<-DESC
  @summary This provider checks an error log from a previous puppet agent
  installation and will fail if the error log exists. The provider will delete
  the existing error log before failing so that after the failed puppet run the
  user can attempt the upgrade again.
  DESC
  def ensure_notexist
    logfile = File.join(Puppet['statedir'].to_s, @resource[:name])
    Puppet.debug "Checking for Error logfile #{logfile}"
    !File.exist?(logfile)
  end

  def read_content_and_delete_file(filename)
    logfile = File.join(Puppet['statedir'].to_s, filename)
    Puppet.debug "Reading Error Log #{logfile}"
    content = if Puppet.features.microsoft_windows?
                # The file laid down by the installation script on windows will be UTF-16LE.
                # In this scenario we need to open the file in binmode and read each line
                # individually, then encode the result back to UTF-8 so we can sub out both
                # the UTF-16 header \uFEFF and the \r\n line carriages.
                File.open(logfile, 'rb:UTF-16LE') { |file| file.readlines }[0].encode!('UTF-8').delete("\uFEFF").delete("\r")
              else
                File.read(logfile)
              end
    Puppet.debug 'Deleting Error Log'
    File.delete(logfile)
    content
  end
end
