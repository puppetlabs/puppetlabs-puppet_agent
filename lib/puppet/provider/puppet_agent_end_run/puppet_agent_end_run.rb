
Puppet::Type.type(:puppet_agent_end_run).provide :puppet_agent_end_run do
  desc '@summary This provider will stop the puppet agent run after a Puppet upgrade is performed'
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
      # Package name might be different to puppet-agent, hence we need to look it up.
      package_name = @resource.catalog.resource('class', 'puppet_agent')[:package_name]
 
      # Latest version might be undefined, e.G. if we're about to install a different named
      # package  than the currently running one. In that case, we'll leave desired_version empty.
      latest_version = @resource.catalog.resource('package', package_name).parameters[:ensure].latest
      desired_version = latest_version.match(%r{^(?:[0-9]:)?(\d+\.\d+(\.\d+)?(?:\.\d+))?}).captures.first unless latest_version.nil?
    end

    Puppet::Util::Package.versioncmp(desired_version, current_version) != 0
  end
end
