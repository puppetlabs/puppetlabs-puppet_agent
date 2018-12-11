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
      # @return [Array<Beaker::Host>] A set of beaker hosts which have the `agent` role but not the `master` role
      def agents_only
        hosts_as(:agent).reject { |host| host['roles'].include?('master') }.to_a
      end
    end

    # Helpers for testing the puppetlabs-puppet_agent module with Beaker
    module Helpers
      # Purging puppet-agent between the tests requires a helper script for some
      # platforms (for example, on Windows). This directory holds those scripts.
      SUPPORTING_FILES = File.expand_path('./files').freeze

      PE_ONLY_PLATFORMS = ['aix', 'amazon', 'sles', 'solaris', 'osx']

      # Check for one or more environment variables and fail the test if they are not present
      # @param [Array<String>] *names Any number of required environment variables
      def expect_environment_variables(*names)
        names.each do |name|
          fail_test("Please set the $#{name} environment variable") unless ENV[name]
        end
      end

      # Gather arguments for {Beaker::DSL::Helpers.install_puppet_agent_on}
      # based on the environment, sanity check them, and format them for use in
      # this module's tests. **This helper should be used this whenever
      # {Beaker::DSL::Helpers.install_puppet_agent_on} is called.** The agent
      # version is selected as follows:
      #
      #   - First, it attempts to determine an exact version of the agent to install, based on:
      #     - `ENV['FROM_AGENT_VERSION']`, or, failing that,
      #     - `ENV['PUPPET_CLIENT_VERSION']` (this was the name of the
      #       equivalent environment variable in version 1.x of this module).
      #   - If an exact version isn't available:
      #     - `ENV['FROM_PUPPET_COLLECTION']` is checked to try to identify a
      #       puppet collection to install from; Valid values here are `puppet5`
      #       (latest release in the puppet 5 series), `puppet6` (latest release
      #       in the puppet 6 series), and `pc1` (legacy, refers to the latest
      #       release in the puppet 4 series.
      #   - If none of the above is available, the `pc1` collection is used:
      #     this selects the latest release of puppet-agent that uses Puppet 4.
      #
      # @see BeakerPuppet::Helpers::install_puppet_agent_on
      # @raise [Beaker::DSL::Outcomes::FailTest] Raises when a specific version
      #   of puppet-agent has been selected to install, but the SUT does not have
      #   access to the internal Puppet build servers where these are hosted.
      # @return [Hash] An options hash to pass to BeakerPuppet's `install_puppet_agent_on` method
      def agent_install_options
        agent_version = ENV['FROM_AGENT_VERSION'] || ENV['PUPPET_CLIENT_VERSION'] # This is the legacy name from puppet 3 / module 1.x

        if agent_version
          unless dev_builds_accessible?
            # The user requested a specific build, but they can't download from internal sources
            env_var_name = ENV['FROM_AGENT_VERSION'] ? 'FROM_AGENT_VERSION' : 'PUPPET_CLIENT_VERSION'
            fail_test(<<-WHY
  You requested a specific build of puppet-agent, but you don't have access to
  Puppet's internal build servers. You can either:

  - Unset the #{env_var_name} environment variable to accept the latest Puppet 4
    agent release (this is the default), or
  - Set the $FROM_PUPPET_COLLECTION environment variable to 'puppet5' or 'puppet6' to
    use the latest releases from the 5 or 6 series.

            WHY
            )
          end

          return { puppet_agent_version: agent_version }
        end

        { puppet_collection: (ENV['FROM_PUPPET_COLLECTION'] || 'pc1').downcase }
      end

      # Use `puppet module install` to install the puppet_agent module's
      # dependencies on the target host, and then install the puppet_agent
      # module itself. Requires that puppet is installed in advance.
      # @param [Beaker::Host] host The target host
      def install_modules_on(host)
        on(host, puppet('module', 'install', 'puppetlabs-stdlib',     '--version', '5.1.0'), { acceptable_exit_codes: [0] })
        on(host, puppet('module', 'install', 'puppetlabs-inifile',    '--version', '2.4.0'), { acceptable_exit_codes: [0] })
        on(host, puppet('module', 'install', 'puppetlabs-apt',        '--version', '6.0.0'), { acceptable_exit_codes: [0] })

        install_dev_puppet_module_on(host,
                                     source: File.join(File.dirname(__FILE__), '..', ),
                                     module_name: 'puppet_agent')
      end

      # Install puppet-agent on all agent nodes at the version determined by
      # {agent_install_options}, and connect them to the master. This is
      # intended to prepare SUTs for tests that upgrade puppet-agent from some
      # initial version.
      def run_setup
        logger.notify("Setup: Install puppet-agent on agents")

        master_agent_version = puppet_agent_version_on(master)
        fail_test("Expected puppet-agent to already be installed on the master, but it was not; make sure you have run the pre-suite tests") unless master_agent_version

        master_fqdn = on(master, 'facter fqdn').stdout.strip

        # Install the puppet-agent package and stop the firewalls
        install_options = agent_install_options
        agents_only.each do |agent|
          if install_options[:puppet_agent_version] && dev_builds_accessible_on?(agent)
            # Install from internal sources
            install_puppet_agent_from_dev_builds_on(agent, install_options[:puppet_agent_version])
          else
            # Attempt to install from public sources; Won't work for PE platforms
            install_puppet_agent_on(agent, agent_install_options)
          end

          stop_firewall_with_puppet_on(agent)

          configure_puppet_on(agent, {
              'main' => { 'server' => master_fqdn },
          })
        end

        logger.notify("Setup: connect agents to master")

        generate_and_sign_certificates

        agents_only.each do |agent|
          fail_test("Failed to install puppet-agent on #{agent} during setup") unless puppet_agent_version_on(agent)
        end
      end

      # Purge puppet-agent and this module's `pc_repo` repository (if present)
      # from all agents (but _not_ from the master).
      def run_teardown
        logger.notify("Teardown: Purge puppet from agents")

        agents_only.each do |host|
          next unless puppet_agent_version_on(host)

          if host['platform'] =~ /windows/
            scp_to(host, "#{SUPPORTING_FILES}/uninstall.ps1", "uninstall.ps1")
            on(host, 'rm -rf C:/ProgramData/PuppetLabs')
            on(host, 'powershell.exe -File uninstall.ps1 < /dev/null')
          else
            manifest_lines = []
            # Remove pc_repo:
            # Note pc_repo is specific to this module's manifests. This is knowledge we need to clean from the machine after each run.
            if host['platform'] =~ /debian|ubuntu/
              on(host, puppet('module', 'install', 'puppetlabs-apt'), { acceptable_exit_codes: [0] })
              manifest_lines << "include apt"
              manifest_lines << "apt::source { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
            elsif host['platform'] =~ /fedora|el|centos/
              manifest_lines << "yumrepo { 'pc_repo': ensure => absent, notify => Package['puppet-agent'] }"
            end

            manifest_lines << "file { ['/etc/puppet', '/etc/puppetlabs', '/etc/mcollective']: ensure => absent, force => true, backup => false }"

            if host['platform'] =~ /^(osx|solaris)/
              # The macOS pkgdmg and Solaris sun providers don't support 'purged':
              manifest_lines << "package { ['puppet-agent']: ensure => absent }"
            else
              manifest_lines << "package { ['puppet-agent']: ensure => purged }"
            end

            on(host, puppet('apply', '-e', %("#{manifest_lines.join("\n")}"), '--no-report'), acceptable_exit_codes: [0, 2])
          end
        end
      end

      # Wraps {Beaker::DSL::PuppetHelpers.with_puppet_running_on} to apply a default
      # manifest to all nodes and execute a block. Behaves as follows:
      #
      # 1. Set up a `site.pp` file in the production environment on the master
      #    such that the puppet code in `site_pp_contents` is applied to all nodes.
      #    - If a `site.pp` already exists there, record its contents and
      #      permissions and create a teardown task to restore them after the test
      #      finishes.
      # 2. Using {Beaker::DSL::PuppetHelpers.with_puppet_running_on}:
      #    - Perform a puppet run on the agents, and
      #    - execute the block, if any.
      #
      # @see Beaker::DSL::PuppetHelpers.with_puppet_running_on
      # @param [String] site_pp_contents The contents of the default site.pp file. This
      #   content will be wrapped as follows, so that it applies to all nodes:
      #     ```
      #     node default {
      #       #{site_pp_contents}
      #     }
      #     ```
      # @param [Hash] master_opts Options to pass to {Beaker::DSL::PuppetHelpers.with_puppet_running_on}.
      # @yield [self] Invokes {Beaker::DSL::PuppetHelpers.with_puppet_running_on}, passing along master_opts, if supplied.
      def with_default_site_pp(site_pp_contents, master_opts = {})
        manifest_contents = %(node default { #{site_pp_contents} })

        # PMT will have installed dependencies in the production environment; Put our manifest there, too:
        site_pp_path = File.join(master.puppet['environmentpath'], 'production', 'manifests', 'site.pp')

        if file_exists_on(master, site_pp_path)
          original_contents = file_contents_on(master, site_pp_path)
          original_perms = on(master, %(stat -c "%a" #{site_pp_path})).stdout.strip

          teardown do
            on(master, %(echo "#{original_contents}" > #{site_pp_path}))
            on(master, %(chmod #{original_perms} #{site_pp_path}))
          end
        else
          teardown do
            on(master, "rm -f #{site_pp_path}")
          end
        end

        create_remote_file(master, site_pp_path, manifest_contents)
        on(master, "chmod 755 #{site_pp_path}")

        with_puppet_running_on(master, master_opts) do
          on(agents_only, puppet("agent --test --server #{master.hostname}"), acceptable_exit_codes: [0, 2])
          yield if block_given?
        end
      end
    end
  end
end
