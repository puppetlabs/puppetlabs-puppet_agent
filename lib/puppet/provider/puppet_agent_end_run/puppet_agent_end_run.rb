Puppet::Type.type(:puppet_agent_end_run).provide :puppet_agent_end_run do
  def end_run
    false
  end

  def stop
    return unless needs_upgrade?

    run_mode = Puppet.run_mode.name

    # Handle CLI runs of `puppet agent` and `apply`
    if Puppet[:onetime] || run_mode != :agent
      Puppet.notice('Stopping run after puppet-agent upgrade. Run puppet agent -t or apply your manifest again to finish the transaction.')
    end

    Puppet::Application.stop!

    # Sending the HUP signal to the daemon causes it to restart and finish applying the catalog
    return unless Puppet[:daemonize] && run_mode == :agent

    at_exit { Process.kill(:HUP, Process.pid) }
  end

  private

  def needs_upgrade?
    current_version = Facter.value('aio_agent_version')
    desired_version = @resource.name

    return false if desired_version == 'present'

    if desired_version == 'latest'
      latest_version = @resource.catalog.resource('package', 'puppet-agent').parameters[:ensure].latest
      desired_version = latest_version.match(%r{^(?:[0-9]:)?(\d+\.\d+(\.\d+)?(?:\.\d+))?}).captures.first
    end

    Puppet::Util::Package.versioncmp(desired_version, current_version) != 0
  end
end
