require 'beaker-puppet'

module Beaker
  module DSL
    # Host selectors by role
    module Roles
      # Select any hosts which have the agent role and are not the master.
      # Beaker's `agents` selector selects all of the hosts that have the
      # `agent` role, but some masters may have _both_ the agent and master
      # roles. This `agents_only` selector will not include any agent hosts that
      # have the `master` role.
      #
      # @return [Array<Beaker::Host>] A set of beaker hosts which have the `agent` role but not the `master` role
      def agents_only
        hosts_as(:agent).reject { |host| host['roles'].include?('master') }.to_a
      end
    end

    module Structure
      def collection_cmp(col_1, col_2)
        col_1 = col_1.to_sym
        col_2 = col_2.to_sym

        return 0 if col_1 == col_2

        return -1 if col_1.casecmp('PC1').zero?
        return 1 if col_2.casecmp('PC1').zero?

        col_1 <=> col_2
      end
      private :collection_cmp

      # Restricts the test on the master's puppetserver collection. There are two
      # types of restrictions that can be applied
      #
      # * Restrict the test to only run on a specific puppetserver collection. Here's
      # an example of how you can specify this restriction:
      #
      # test_name 'an agent upgrade test' do
      #   require_master_collection 'puppet5'
      # end
      #
      # This will run the test if the master's puppetserver is from the puppet5 collection;
      # otherwise, the test will be skipped.
      #
      # * Restrict the test to run on a valid range of collections. There are several ways
      # you can specify this restriction:
      #
      # test_name 'an agent upgrade test' do
      #   require_master_collection min: 'PC1', max: 'puppet5'
      # end
      #
      # test_name 'an agent upgrade test' do
      #   require_master_collection min: 'PC1'
      # end
      #
      # test_name 'an agent upgrade test' do
      #   require_master_collection max: 'puppet6'
      # end
      #
      # The first restriction will only run the test if the master's puppetserver is from
      # the puppet4 collection or newer, but no newer than puppet5. The second restriction
      # will only run the test if the master's puppetserver is from the puppet4 collection
      # or newer. The third restriction will only run the test if the master's puppetserver
      # is from the puppet6 collection or older.
      #
      # NOTE: Be sure to put this DSL first in your test, before any confines. Otherwise,
      # you could accidentally filter out your master and thus raise an exception here.
      #
      # @param [Symbol|String|Hash] args The specified restriction
      def require_master_collection(args)
        args = args.to_sym if args.is_a?(String)

        args_are_not_a_valid_hash =
          ! args.is_a?(Hash) ||
          args.empty? ||
          ! Set[*args.keys].subset?(Set[:restrict_to, :max, :min])

        if (! args.is_a?(Symbol)) && args_are_not_a_valid_hash
          fail_test("The require_master_collection DSL structure accepts ether a String/Symbol that specifies the collection, or a non-empty Hash consisting of only the keys :max or :min. You passed-in an argument of type #{args.class} with value #{args}.")
        end

        server_version = puppetserver_version_on(master)
        server_collection = puppet_collection_for(:puppetserver, server_version)
        msg_prefix = "This master is set up with a puppetserver from the #{server_collection} collection."

        if args.is_a?(Symbol)
          collection = args.to_s
          unless server_collection == collection
            skip_test(msg_prefix + "\nThis test requires a puppetserver from the #{collection} collection. Skipping the test ...")
          end

          return
        end

        # At this part of the method, we are guaranteed that at least one of
        # min_collection and max_collection are specified
        min_collection = args[:min]
        max_collection = args[:max]

        if min_collection.nil?
          # only max_collection is specified
          if collection_cmp(max_collection, server_collection) < 0
            skip_test(msg_prefix + " This test requires a puppetserver from the #{max_collection} collection or older. Skipping the test ...")
          end
        elsif max_collection.nil?
          # only min_collection is specified
          if collection_cmp(server_collection, min_collection) < 0
            skip_test(msg_prefix + " This test requires a puppetserver from the #{min_collection} collection or newer. Skipping the test ...")
          end
        else
          # both min_collection and max_collection are specified
          if collection_cmp(server_collection, min_collection) < 0 || collection_cmp(max_collection, server_collection) < 0
            skip_test(msg_prefix + " This test requires a puppetserver that's from the #{min_collection} collection or newer, but not newer than the #{max_collection} collection. Skipping the test ...")
          end
        end
      end

      # Filters out any PE-only agent upgrade candidates.
      #
      # Here's an example of how this DSL is used:
      #
      # test_name 'an agent upgrade test' do
      #   exclude_pe_upgrade_platforms
      # end
      #
      # Here, all agents with PE-only upgrades are filtered out from the
      # hosts variable.
      #
      # NOTE: Be sure to put this DSL above all other confines in the test.
      # Otherwise, you could have something like:
      #
      # test_name 'an agent upgrade test' do
      #   confine :to, platform: windows
      #   exclude_pe_upgrade_platforms
      # end
      #
      # This is bad because the first confine would accidentally filter out
      # the master.
      def exclude_pe_upgrade_platforms
        # We cannot just do confine :except, platform: <pe_upgrade_platforms>
        # because that may accidentally filter out the master.
        confine :to, {} do |host|
          next true if host['roles'].include?('master')

          ! %w[aix amazon sles solaris osx].include?(host['platform'])
        end
      end
    end

    # Helpers for testing the puppetlabs-puppet_agent module with Beaker
    module Helpers
      # Purging puppet-agent between the tests requires a helper script for some
      # platforms (for example, on Windows). This directory holds those scripts.
      SUPPORTING_FILES = File.expand_path('./files').freeze


      # Add new environment to the puppet master. This environment will be usable
      # from any connected agents.
      def new_puppet_testing_environment
        environment_name = 'puppet_agent_testing_' + SecureRandom.hex(10).to_s
        puppet_testing_environment = environment_location(environment_name)
        step '(Master) Create test environment' do
          on(master, "mkdir -p #{File.join(puppet_testing_environment, 'modules')}")
          on(master, "mkdir -p #{File.join(puppet_testing_environment, 'manifests')}")
        end
        step '(Master) Install puppet_agent to the test environment' do
          install_puppet_agent_module_on(master, environment_name)
        end
        return environment_name
      end

      # Use `puppet module install` to install the puppet_agent module's
      # dependencies on the target host, and then install the puppet_agent
      # module itself. The function will install the modules to the environment
      # specified in the 'environment' param. Requires that puppet is installed in advance.
      #
      # @param [Beaker::Host] host The target host
      # @param [String] environment The puppet environment to install the modules to, this must
      #   be a valid environment in the puppet install on the host.
      def install_puppet_agent_module_on(host, environment)
        on(host, puppet('module', 'install', 'puppetlabs-stdlib',     '--version', '5.1.0', '--environment', environment), { acceptable_exit_codes: [0] })
        on(host, puppet('module', 'install', 'puppetlabs-inifile',    '--version', '2.4.0', '--environment', environment), { acceptable_exit_codes: [0] })
        on(host, puppet('module', 'install', 'puppetlabs-apt',        '--version', '6.0.0', '--environment', environment), { acceptable_exit_codes: [0] })

        install_dev_puppet_module_on(host,
                                     source: File.join(File.dirname(__FILE__), '..', ),
                                     module_name: 'puppet_agent',
                                     target_module_path: File.join(environment_location(environment), 'modules'))
      end

      # Find the fully qualified path to the 'environment_name' environment on the puppet master
      #
      # @param [String] environment_name the name of the environment to find
      def environment_location(environment_name)
        File.join(puppet_config(master, 'codedir'), 'environments', environment_name)
      end

      # Read as "host_to_informative_string".
      #
      # @param [Beaker::Host] host The host
      # @return An informative string of the form <host_name> (<host_platform>)
      def host_to_info_s(host)
        "#{host} (#{host['platform']})"
      end


      # Installs an initial puppet agent package on a host and connect the new agent node to the
      # puppet master. This 'initial' agent is likely a lower version than the puppet master on
      # purpose to facilitate an upgrade scenario.
      #
      # @param [Beaker::Host] host The host
      # @param [String] initial_package_version_or_collection Either a version
      #   of puppet-agent or the name of a puppet collection to install the agent from.
      def set_up_initial_agent_on(host, initial_package_version_or_collection)
        master_agent_version = fact_on(master, 'aio_agent_version')
        unless master_agent_version
          fail_test('Expected puppet-agent to already be installed on the master, but it was not. ' \
                    'Try running the `prepare` rake task.')
        end

        # We use the teardowns lambdas in this setup helper so that teardowns for installations
        # only appear after the installation has actually occured, rather than seeing failed
        # teardown statements when the helper fails before an installation can occur but the helper
        # still tries the uninstall helper.
        teardowns = []

        step 'Set-up the agents to upgrade' do
          step '(Agent) Install the puppet-agent package' do
            initial_package_version_or_collection ||= master_agent_version
            if initial_package_version_or_collection =~ /(^pc1$|^puppet\d+)/i
              agent_install_options = { puppet_collection: initial_package_version_or_collection }
            else
              agent_install_options = {
                puppet_agent_version: initial_package_version_or_collection,
                puppet_collection: puppet_collection_for(:puppet_agent, initial_package_version_or_collection)
              }
            end

            install_puppet_agent_on(host, agent_install_options)
            teardowns << lambda do
              remove_installed_agent(host)
            end
          end
          step '(Agent) Clear SSL and stop firewalls' do
            ssldir = puppet_config(host, 'ssldir').strip
            on(host, "rm -rf '#{ssldir}'/*") # Preserve the directory itself, to keep permissions

            stop_firewall_with_puppet_on(host)
          end

          step '(Agent) Stop the puppet service to avoid possible race conditions with conflicting Puppet runs' do
            on(host, puppet('resource', 'service', 'puppet', 'ensure=stopped'))
          end

          server_version = puppetserver_version_on(master)

          step '(Agent) configure server setting on agent' do
            on(host, puppet("config set server #{master}"))
          end

          step '(Agent) Run puppet agent -t to generate CSRs' do
            on(host, puppet("agent -t"), acceptable_exit_codes: [1])
          end

          agent_certname = fact_on(host, 'fqdn')
          step '(Master) Sign certs' do
            if version_is_less('5.99.99', server_version)
              on(master, "puppetserver ca sign --certname #{agent_certname}")
            else
              on(master, puppet("cert sign #{agent_certname}"))
            end
          end

          teardowns << lambda do
            clean_agent_certificate(agent_certname)
          end

          step '(Agent) Run puppet agent -t again to obtain the signed cert and apply initial configuration' do
            on(host, puppet("agent -t"), acceptable_exit_codes: [0, 2])
          end
        end
        yield if block_given?
      ensure
        if teardowns && ! teardowns.empty?
          teardowns.each do |_teardown|
            teardown(&_teardown)
          end
        end
      end


      # Asserts a successful upgrade by asserting that all of the
      # agents were upgraded to the expected version.
      #
      # @param [Beaker::Host] host The host
      # @param [String] expected_version The expected version that
      #   the agents should be upgraded to
      def assert_agent_version_on(host, expected_version)
        installed_version = puppet_agent_version_on(host)

        assert_equal(expected_version, installed_version,
                      "Expected '#{host_to_info_s(host)}' agent to be upgraded to puppet-agent #{expected_version}, but detected '#{installed_version}' instead")
      end

      # Start the puppet service on a host and wait for it's
      # first run to finish. Waiting is perforned by diffing the mtime
      # of the last_run_report before the service was started and waiting
      # for it to change.
      #
      # @param [Beaker::Host] host The host
      def start_puppet_service_and_wait_for_puppet_run(host)
        statedir = on(host, puppet('config', 'print', 'statedir')).stdout.chomp
        # Get modification time of last_run_report
        mtime_cmd = "File.stat(\"#{statedir}/last_run_report.yaml\").mtime.to_i"
        last_run_time = on(host, "env PATH=\"#{host['privatebindir']}:${PATH}\" ruby -e 'puts #{mtime_cmd}'").stdout.chomp
        step "(Agent) Enable agent's puppet service to perform the agent upgrade from puppet service" do
          on(host, puppet('resource', 'service', 'puppet', 'ensure=running'))
        end
        # wait for Puppet to have finished, i.e. retry until last_run_report modification time has changed
        step "(Agent) waiting for puppet run to complete..." do
          retry_on(host, "env PATH=\"#{host['privatebindir']}:${PATH}\" ruby -e 'exit #{mtime_cmd} > #{last_run_time}'", {:max_retries => 1000, :retry_interval => 2})
        end

        step "(Agent) waiting for puppet to exit..." do
          retry_on(host, "cat #{statedir}/agent_catalog_run.lock", {:desired_exit_codes => [1, 2]})
        end
      end

      # Wait for the installation pidfile on a host to indicate an installation has finished.
      # pidfiles are only created on windows/MacOS/Solaris platforms so this function
      # will return immediately for anything else.
      #
      # @param [Beaker::Host] host The host
      def wait_for_installation_pid(host)
        case host['platform']
        when /windows/
          upgrade_pidfile = 'C:/ProgramData/PuppetLabs/puppet/cache/state/puppet_agent_upgrade.pid'
        when /(solaris|osx)/
          upgrade_pidfile = '/opt/puppetlabs/puppet/cache/state/puppet_agent_upgrade.pid'
        else
          # All other platforms will have an agent run execute _through_ the installation, rather than
          # having to exit the agent and wait for an external script to perform the upgrade
          return
        end

        step "(Agent) waiting for upgrade pid file to be created..." do
          retry_on(host, "cat #{upgrade_pidfile}", {:max_retries => 5, :retry_interval => 2})
        end

        step "(Agent) waiting for upgrade to complete..." do
          retry_on(host, "cat #{upgrade_pidfile}", {:max_retries => 1000, :retry_interval => 2, :desired_exit_codes => [1, 2]})
        end
      end

      # Remove an a currently installed agent from a host, this should be a 'clean' installation that
      # includes removal of things like the codedir.
      #
      # @param [Beaker::Host] host The host
      def remove_installed_agent(host)
        step '(Agent) Stop the puppet service' do
          on(host, puppet('resource', 'service', 'puppet', 'ensure=stopped'))
        end

        step "Teardown: (Agent) Uninstall the puppet-agent package on agent #{host_to_info_s(host)}" do
          if host['platform'] =~ /windows/
            scp_to(host, "#{SUPPORTING_FILES}/uninstall.ps1", "uninstall.ps1")
            on(host, 'rm -rf C:/ProgramData/PuppetLabs')
            on(host, 'powershell.exe -File uninstall.ps1 < /dev/null')
          else
            manifest_lines = []
            # Remove pc_repo:
            # Note pc_repo is specific to this module's manifests. This is
            # knowledge we need to clean from the machine after each run.
            if host['platform'] =~ /debian|ubuntu/
              on(host, puppet('module', 'install', 'puppetlabs-apt'), acceptable_exit_codes: [0])
              manifest_lines << 'include apt'
              manifest_lines << "apt::source { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
            elsif host['platform'] =~ /fedora|el|centos/
              manifest_lines << "yumrepo { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
            end

            manifest_lines << "file { ['/etc/puppet', '/etc/puppetlabs', '/etc/mcollective']: ensure => absent, force => true, backup => false }"

            if host['platform'] =~ /^(osx|sles|solaris)/
              # The macOS pkgdmg, SLES zypper, and Solaris sun providers don't support 'purged':
              manifest_lines << "package { ['puppet-agent']: ensure => absent }"
            else
              manifest_lines << "package { ['puppet-agent']: ensure => purged }"
            end

            on(host, puppet('apply', '-e', %("#{manifest_lines.join("\n")}"), '--no-report'), acceptable_exit_codes: [0, 2])
          end
        end
      end

      # Remove an agent certificate from the master cert store.
      #
      # @param [String] agent_certname The name of the cert to remove from the master
      def clean_agent_certificate(agent_certname)
        step "Teardown: (Master) Clean agent #{agent_certname} cert" do
          if version_is_less('5.99.99', puppetserver_version_on(master))
            on(master, "puppetserver ca clean --certname #{agent_certname}")
          else
            on(master, puppet("cert clean #{agent_certname}"))
          end
        end
      end
    end
  end
end
