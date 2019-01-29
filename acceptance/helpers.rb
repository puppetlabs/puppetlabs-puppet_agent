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

        return -1 if col_1 == 'pc1'
        return 1 if col_2 == 'pc1'

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
      #   require_master_collection min: 'puppet4', max: 'puppet5'
      # end
      #
      # test_name 'an agent upgrade test' do
      #   require_master_collection min: 'puppet4'
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
        msg_prefix = "This master is set-up with a puppetserver from the #{server_collection} collection."

        if args.is_a?(Symbol)
          collection = args.to_s
          unless server_collection == collection
            skip_test(msg_prefix + " This test requires a puppetserver from the #{collection} collection. Skipping the test ...")
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

      # Use `puppet module install` to install the puppet_agent module's
      # dependencies on the target host, and then install the puppet_agent
      # module itself. Requires that puppet is installed in advance.
      #
      # @param [Beaker::Host] host The target host
      def install_puppet_agent_module_on(host)
        on(host, puppet('module', 'install', 'puppetlabs-stdlib',     '--version', '5.1.0'), { acceptable_exit_codes: [0] })
        on(host, puppet('module', 'install', 'puppetlabs-inifile',    '--version', '2.4.0'), { acceptable_exit_codes: [0] })
        on(host, puppet('module', 'install', 'puppetlabs-apt',        '--version', '6.0.0'), { acceptable_exit_codes: [0] })

        install_dev_puppet_module_on(host,
                                     source: File.join(File.dirname(__FILE__), '..', ),
                                     module_name: 'puppet_agent')
      end

      # Read as "host_to_informative_string".
      #
      # @param [Beaker::Host] host The host
      # @return An informative string of the form <host_name> (<host_platform>)
      def host_to_info_s(host)
        "#{host} (#{host['platform']})"
      end

      # Install puppet-agent on all agent nodes and connects them to the master.
      # This is intended to set-up SUTs for tests that upgrade puppet-agent
      # from some initial version. A key post-condition of this method is that
      # all of the agents are ready to be upgraded with the puppet_agent module.
      #
      # @param [String] initial_package_version_or_collection Either a version
      #   of puppet-agent or the name of a puppet collection to install the agent from.
      # @yield Invokes any additional setup that's required. 
      def set_up_agents_to_upgrade(initial_package_version_or_collection)
        master_agent_version = fact_on(master, 'aio_agent_version')
        unless master_agent_version
          fail_test('Expected puppet-agent to already be installed on the master, but it was not. ' \
                    'Try running the `prepare` rake task.')
        end

        # This variable should be read as teardowns::clean_agents. It stores the
        # teardowns we'll need to invoke to clean our agents
        teardowns__clean_agents = []

        step 'Set-up the agents to upgrade' do
          step '(Agents) Install the puppet-agent package' do
            initial_package_version_or_collection ||= master_agent_version
            if initial_package_version_or_collection =~ /(^pc1$|^puppet\d+)/i
              agent_install_options = { puppet_collection: initial_package_version_or_collection }
            else
              agent_install_options = {
                puppet_agent_version: initial_package_version_or_collection,
                puppet_collection: puppet_collection_for(:puppet_agent, initial_package_version_or_collection)
              }
            end

            agents_only.each do |agent|
              install_puppet_agent_on(agent, agent_install_options)

              teardowns__clean_agents << lambda do
                step "Teardown: Uninstall the puppet-agent package on agent #{host_to_info_s(agent)}" do
                  if agent['platform'] =~ /windows/
                    scp_to(agent, "#{SUPPORTING_FILES}/uninstall.ps1", "uninstall.ps1")
                    on(agent, 'rm -rf C:/ProgramData/PuppetLabs')
                    on(agent, 'powershell.exe -File uninstall.ps1 < /dev/null')
                  else
                    manifest_lines = []
                    # Remove pc_repo:
                    # Note pc_repo is specific to this module's manifests. This is
                    # knowledge we need to clean from the machine after each run.
                    if agent['platform'] =~ /debian|ubuntu/
                      on(agent, puppet('module', 'install', 'puppetlabs-apt'), acceptable_exit_codes: [0])
                      manifest_lines << 'include apt'
                      manifest_lines << "apt::source { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
                    elsif agent['platform'] =~ /fedora|el|centos/
                      manifest_lines << "yumrepo { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
                    end

                    manifest_lines << "file { ['/etc/puppet', '/etc/puppetlabs', '/etc/mcollective']: ensure => absent, force => true, backup => false }"

                    if agent['platform'] =~ /^(osx|solaris)/
                      # The macOS pkgdmg and Solaris sun providers don't support 'purged':
                      manifest_lines << "package { ['puppet-agent']: ensure => absent }"
                    else
                      manifest_lines << "package { ['puppet-agent']: ensure => purged }"
                    end

                    on(agent, puppet('apply', '-e', %("#{manifest_lines.join("\n")}"), '--no-report'), acceptable_exit_codes: [0, 2])
                  end
                end
              end
            end
          end

          step '(Agents) Clear SSL and stop firewalls' do
            agents_only.each do |agent|
              ssldir = puppet_config(agent, 'ssldir').strip
              on(agent, "rm -rf '#{ssldir}'/*") # Preserve the directory itself, to keep permissions

              stop_firewall_with_puppet_on(agent)
            end
          end

          step '(Agents) Stop the puppet service to avoid possible race conditions with conflicting Puppet runs' do
            on(agent, puppet('resource', 'service', 'puppet', 'ensure=stopped'))
          end

          server_version = puppetserver_version_on(master)
          agent_certnames = []

          step '(Agents) Run puppet agent -t to generate CSRs' do
            agents_only.each do |agent|
              on(agent, puppet("agent --test --server #{master}"), acceptable_exit_codes: [1])

              # We cannot calculate this in the teardown block because the puppet-agent
              # package, and hence facter, will have already been uninstalled by the time
              # this block is invoked.
              agent_certname = fact_on(agent, 'fqdn')
              agent_certnames << agent_certname

              teardowns__clean_agents << lambda do
                step "Teardown: (Master) Clean agent '#{host_to_info_s(agent)}'s cert " do
                  if version_is_less('5.99.99', server_version)
                    on(master, "puppetserver ca clean --certname #{agent_certname}")
                  else
                    on(master, puppet("cert clean #{agent_certname}"))
                  end
                end
              end
            end
          end

          step '(Master) Sign certs' do
            if version_is_less('5.99.99', server_version)
              on(master, "puppetserver ca sign --certname #{agent_certnames.join(',')}")
            else
              on(master, puppet("cert sign #{agent_certnames.join(' ')}"))
            end
          end

          step '(Agents) Run puppet agent -t again to obtain the signed cert' do
            on(agents_only, puppet("agent --test --server #{master}"), acceptable_exit_codes: [0])
          end

          # Do any additional setup
          yield if block_given?
        end
      ensure
        if teardowns__clean_agents && ! teardowns__clean_agents.empty?
          teardowns__clean_agents.each do |teardown__clean_agents|
            teardown(&teardown__clean_agents)
          end
        end
      end

      # Applies a manifest on the agents. Behaves as follows:
      #
      # 1. Set up a `site.pp` file in the production environment on the master
      #    such that the puppet code in `manifest` is applied _only_ on the agents.
      #    - If a `site.pp` already exists there, record its contents and
      #      permissions, then restore them after the method's invoked.
      #
      # 2. Perform a puppet run on the agents
      #
      # @param [String] manifest The manifest to apply. This content will
      #   be wrapped as follows, so that it applies to all of the agents:
      #     ```
      #     node '#{agent1}', '#{agent2}' ... {
      #       #{manifest}
      #     }
      def apply_manifest_on_agents(manifest)
        agent_nodes = agents_only.map do |agent|
          "'#{agent.to_s}'"
        end.join(', ')
        site_pp_contents = %(node #{agent_nodes} { #{manifest} })

        # PMT will have installed dependencies in the production environment; We will put our manifest there, too:
        site_pp_path = File.join(puppet_config(master, 'codedir'), 'environments', 'production', 'manifests', 'site.pp')

        cleanup = nil

        step "(Master) Save the current site.pp file" do
          if file_exists_on(master, site_pp_path)
            original_contents = file_contents_on(master, site_pp_path)
            original_perms = on(master, %(stat -c "%a" #{site_pp_path})).stdout.strip
  
            cleanup = lambda do
              step "(Master) Restore the original site.pp file" do
                on(master, %(echo "#{original_contents}" > #{site_pp_path}))
                on(master, %(chmod #{original_perms} #{site_pp_path}))
              end
            end
          else
            cleanup = lambda do
              on(master, "rm -f #{site_pp_path}")
            end
          end
        end

        step "(Master) Create the new site.pp file with manifest:\n#{manifest}" do
          create_remote_file(master, site_pp_path, manifest)
          on(master, %(chown #{puppet_user(master)} "#{site_pp_path}"))
          on(master, %(chmod 755 "#{site_pp_path}"))
        end

        step "(Agents) Run Puppet to apply the manifest" do
          on(agents_only, puppet(%(agent --test --server #{master.hostname})), acceptable_exit_codes: [0, 2])
        end
      ensure
        cleanup.call if cleanup
      end

      # Asserts a successful upgrade by asserting that all of the
      # agents were upgraded to the expected version. You can pass-in
      # a block for additional assertions. For example,
      #
      # assert_successful_upgrade('6.0.0') do |agent|
      #   // Additional assertions go here.
      # end
      #
      # @param [String] expected_version The expected version that
      #   the agents should be upgraded to
      # @yield [Beaker::Host] the agent to perform additional assertions
      #   on
      def assert_successful_upgrade(expected_version)
        agents_only.each do |agent|
          installed_version = puppet_agent_version_on(agent)

          assert_equal(expected_version, installed_version,
                       "Expected '#{host_to_info_s(agent)}' agent to be upgraded to puppet-agent #{expected_version}, but detected '#{installed_version}' instead")

          # Additional assertions go here
          yield agent if block_given?
        end
      end
    end
  end
end
