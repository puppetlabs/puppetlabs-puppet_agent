Puppet::Type.type(:puppet_agent_upgrade_error).provide :puppet_agent_upgrade_error do
  def ensure_notexist
    logfile = File.join(Puppet["statedir"].to_s, @resource[:name])
    Puppet.debug "Checking for Error logfile #{logfile}"
    not File.exists?(logfile)
  end

  def read_content_and_delete_file(filename)
    logfile = File.join(Puppet["statedir"].to_s, filename)
    Puppet.debug "Reading Error Log #{logfile}"
    if Puppet.features.microsoft_windows?
      # The file laid down by the installation script on windows will be UTF-16LE.
      # In this scenario we need to open the file in binmode and read each line
      # individually, then encode the result back to UTF-8 so we can sub out both
      # the UTF-16 header \uFEFF and the \r\n line carriages.
      content = File.open(logfile,"rb:UTF-16LE"){ |file| file.readlines }[0].encode!('UTF-8').gsub("\uFEFF",'').gsub("\r",'')
    else
      content = File.read(logfile)
    end
    Puppet.debug "Deleting Error Log"
    File.delete(logfile)
    return content
  end

end
