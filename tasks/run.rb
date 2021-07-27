#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'puppet'

params = JSON.parse(STDIN.read)
require_relative File.join(params['_installdir'], 'puppet_agent', 'files', 'rb_task_helper.rb')


module PuppetAgent
  class Runner
    include PuppetAgent::RbTaskHelper

    def running?(lockfile)
      File.exist?(lockfile)
    end

    def disabled?(lockfile)
      File.exist?(lockfile)
    end


    # Prepare an environment fix-up to make up for its cleansing performed
    # by the Puppet::Util::Execution.execute function.
    # This fix-up is meant for running puppet under a non-root user;
    # puppet cannot find the user's HOME directory otherwise.
    def get_env_fix_up
      # If running in a C or POSIX locale, ask Puppet to use UTF-8
      base_env = {}
      if Encoding.default_external == Encoding::US_ASCII
        base_env = {"RUBYOPT" => "#{ENV['RUBYOPT']} -EUTF-8"}
      end

      @env_fix_up ||= if Puppet.features.microsoft_windows? || Process.euid == 0
        # no environment fix-up is needed on windows or for root
        base_env
      else
        begin
          require 'etc'

          pwentry = Etc.getpwuid(Process.euid)

          {
            "USER"    => pwentry.name,
            "LOGNAME" => pwentry.name,
            "HOME"    => pwentry.dir
          }.merge base_env
        rescue => e
          # Give it a try without the environment fix-up.
          myname = File.basename($0)
          base_env
        end
      end
    end

    def force_unicode(s)
      begin
        # Later comparisons assume UTF-8. Convert to that encoding now.
        s.encode(Encoding::UTF_8)
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
        # Found non-native characters, hope it's a UTF-8 string. Since this is Puppet, and
        # incorrect characters probably means we're in a C or POSIX locale, this is usually safe.
        s.force_encoding(Encoding::UTF_8)
      end
    end

    # Wait for the lockfile to be removed. If it hasn't after 10 minutes, give up.
    def wait_for_lockfile(lockfile, check_interval = 0.1, give_up_after = 10 * 60)
      number_of_tries = give_up_after / check_interval
      count = 0
      while File.exist?(lockfile) && count < number_of_tries
        sleep check_interval
        count += 1
      end
    end

    def get_start_time(last_run_report)
      File.mtime(last_run_report) if File.exist?(last_run_report)
    end

    # Loads the last run report and generates a result from it.
    def get_result_from_report(last_run_report, run_result, start_time)
      unless File.exist?(last_run_report)
        return error_result(
          'puppet_agent/no-last-run-report-error',
          'Did not detect report, Puppet agent may not be configured'
        )
      end

      if start_time && File.mtime(last_run_report) == start_time
        return error_result(
          'puppet_agent/no-last-run-report-error',
          'The Puppet run failed in an unexpected way'
        )
      end

      begin
        report = YAML.parse_file(last_run_report)

        # Drop Ruby objects since these can't be parsed
        report.root.each do |obj|
          obj.tag = nil if obj.respond_to?(:tag=)
        end

        {
          'report'   => report.to_ruby,
          'exitcode' => run_result.exitstatus,
          '_output'  => run_result
        }
      rescue => e
        return error_result(
          'puppet_agent/invalid-last-run-report-error',
          "Report #{last_run_report} could not be loaded: #{e}"
        )
      end
    end

    # Returns the Puppet config for the specified keys. Used to locate the
    # last run report, disabled lockfile, and catalog run lockfile.
    def config_print(*keys)
      command = [puppet_bin, "agent", "--configprint", keys.join(',')]

      options = {
        custom_environment: get_env_fix_up,
        override_locale:    false
      }

      process_output = Puppet::Util::Execution.execute(command, options)

      result = force_unicode(process_output.to_s)
      if keys.count == 1
        result.chomp
      else
        result.lines.inject({}) do |conf, line|
          key, value = line.chomp.split(' = ', 2)
          if key && value
            conf[key] = value
          end
          conf
        end
      end
    end

    # Attempts to run the Puppet agent, returning the mtime for the last run report
    # and the exit code from the Puppet agent run.
    def try_run(last_run_report)
      start_time = get_start_time(last_run_report)

      command = [puppet_bin, 'agent', '-t', '--color', 'false']

      options = {
        failonfail:         false,
        custom_environment: get_env_fix_up,
        override_locale:    false
      }

      run_result = Puppet::Util::Execution.execute(command, options)

      [start_time, run_result]
    end

    # Runs the Puppet agent and returns the last run report.
    def run
      unless puppet_bin_present?
        return error_result(
          'puppet_agent/no-puppet-bin-error',
          "Puppet executable '#{puppet_bin}' does not exist"
        )
      end

      puppet_config   = config_print('lastrunreport', 'agent_disabled_lockfile', 'agent_catalog_run_lockfile')
      last_run_report = puppet_config['lastrunreport']

      if last_run_report.nil? || last_run_report.empty?
        return error_result(
          'puppet_agent/no-last-run-report-error',
          'Could not find the location of the last run report'
        )
      end

      # Initially ignore the lockfile. It might be out-dated, so we give Puppet a chance
      # to clean it up and run.
      start_time, run_result = try_run(last_run_report)
      if run_result.nil?
        return error_result(
          'puppet_agent/fail-to-start-error',
          'Failed to start Puppet agent'
        )
      end

      # If the run was successful, don't check for failure modes.
      if run_result.exitstatus != 0
        if disabled?(puppet_config['agent_disabled_lockfile'] || '')
          return error_result(
            'puppet_agent/agent-disabled-error',
            'Puppet agent is disabled'
          )
        end

        # Check for a lockfile. If present, wait until it's removed and try running again.
        # There's a chance that our run finished with a real error rather than because Puppet was
        # already running, but another run started immediately after. Since we have no
        # language-agnostic way to tell, we accept that we might run twice in that case.
        # The run could also finish immediately after we tried, and the lockfile be absent.
        # In that case we'll fail with poor error reporting.
        lockfile = puppet_config['agent_catalog_run_lockfile'] || ''
        if running?(lockfile)
          wait_for_lockfile(lockfile)

          start_time, run_result = try_run(last_run_report)
          if run_result.nil?
            return error_result(
              'puppet_agent/fail-to-start-error',
              'Failed to start Puppet agent'
            )
          end

          if run_result.exitstatus != 0
            if disabled?(puppet_config['agent_disabled_lockfile'] || '')
              return error_result(
                'puppet_agent/agent-disabled-error',
                'Puppet agent is disabled'
              )
            end

            if running?(lockfile)
              return error_result(
                'puppet_agent/agent-locked-error',
                'Puppet agent run is already in progress'
              )
            end
          end
        end
      end

      get_result_from_report(last_run_report, run_result, start_time)
    end
  end
end

if __FILE__ == $0
  runner = PuppetAgent::Runner.new
  puts JSON.dump(runner.run)
end
