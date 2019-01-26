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

    # Helpers for testing the puppetlabs-puppet_agent module with Beaker
    module Helpers
      # Purging puppet-agent between the tests requires a helper script for some
      # platforms (for example, on Windows). This directory holds those scripts.
      SUPPORTING_FILES = File.expand_path('./files').freeze

      # These platforms are only supported under Puppet Enterprise, and FOSS
      # tests should be skipped on them.
      PE_ONLY_UPGRADES = %w[aix amazon sles solaris osx]

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

      # Install puppet-agent on all agent nodes and connect them to the master.
      # This is intended to prepare SUTs for tests that upgrade puppet-agent
      # from some initial version.
      #
      # @param [String] initial_package_version_or_collection Either a version
      #   of puppet-agent or the name of a puppet collection to install the agent from.
      def prepare_upgrade_with(initial_package_version_or_collection)
        master_agent_version = fact_on(master, 'aio_agent_version')
        unless master_agent_version
          fail_test('Expected puppet-agent to already be installed on the master, but it was not. ' \
                    'Try running the `prepare` rake task.')
        end

        step 'Setup: Prepare agents for upgrade' do
          step 'Install puppet-agent on agent hosts' do
            initial_package_version_or_collection ||= master_agent_version
            if initial_package_version_or_collection =~ /(^pc1$|^puppet\d+)/i
              agent_install_options = { puppet_collection: initial_package_version_or_collection }
            else
              agent_install_options = {
                puppet_agent_version: initial_package_version_or_collection,
                puppet_collection: puppet_collection_for(:puppet_agent, initial_package_version_or_collection)
              }
            end

            block_on(agents_only) do |agent|
              install_puppet_agent_on(agent, agent_install_options)
            end
          end

          step 'Clear SSL and stop firewalls' do
            block_on(agents_only) do |agent|
              ssldir = puppet_config(agent, 'ssldir').strip
              on(agent, "rm -rf '#{ssldir}'/*") # Preserve the directory itself, to keep permissions

              stop_firewall_with_puppet_on(agent)
            end
          end

          step 'Sign certs' do
            master_fqdn = on(master, facter('fqdn')).stdout.strip
            master_hostname = on(master, facter('hostname')).stdout.strip
            master_conf = { 'main' => {
                'autosign'      => true,
                'dns_alt_names' => "puppet,#{master_hostname},#{master_fqdn}",
                'verbose'       => true,
                'daemonize'     => true,
            }}

            with_puppet_running_on(master, master_conf) do
              block_on(agents_only) do |agent|
                on(agent, puppet("agent --test --server #{master}"), acceptable_exit_codes: [0])
              end
            end
          end
        end
      end

      # Purge puppet-agent and this module's `pc_repo` repository (if present)
      # from all agents (but _not_ from the master).
      def purge_agents
        step 'Teardown: purge puppet from agents' do
          step 'Clear agent certs from master' do
            server_version = puppetserver_version_on(master)
            agent_certnames = agents_only.map(&:to_s)
            if version_is_less('5.99.99', server_version)
              on(master, "puppetserver ca clean --certname #{agent_certnames.join(',')}")
            else
              on(master, puppet("cert clean #{agent_certnames.join(' ')}"))
            end
          end

          step 'Uninstall puppet-agent on agents'
          agents_only.each do |agent|
            next unless fact_on(agent, 'aio_agent_version')

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
      # @yield Invokes {Beaker::DSL::PuppetHelpers.with_puppet_running_on},
      # passing along master_opts, if supplied.
      def with_default_site_pp(site_pp_contents, master_opts = {})
        manifest_contents = %(node default { #{site_pp_contents} })

        # PMT will have installed dependencies in the production environment; We will put our manifest there, too:
        site_pp_path = File.join(puppet_config(master, 'codedir'), 'environments', 'production', 'manifests', 'site.pp')

        step "Save current site.pp" do
          if file_exists_on(master, site_pp_path)
            original_contents = file_contents_on(master, site_pp_path)
            original_perms = on(master, %(stat -c "%a" #{site_pp_path})).stdout.strip

            teardown do
              step "restore original manifest" do
                on(master, %(echo "#{original_contents}" > #{site_pp_path}))
                on(master, %(chmod #{original_perms} #{site_pp_path}))
              end
            end
          else
            teardown do
              on(master, "rm -f #{site_pp_path}")
            end
          end
        end

        step "create site.pp on master with manifest:\n#{manifest_contents}" do
          create_remote_file(master, site_pp_path, manifest_contents)
          on(master, %(chown #{puppet_user(master)} "#{site_pp_path}"))
          on(master, %(chmod 755 "#{site_pp_path}"))
        end

        step "Execute puppet runs" do
          with_puppet_running_on(master, master_opts) do
            on(agents_only, puppet(%(agent --test --server #{master.hostname})), acceptable_exit_codes: [0, 2])
            yield if block_given?
          end
        end
      end

      # Wraps {with_default_site_pp} to:
      #
      # - Install the a puppet-agent package (`initial_package_version_or_collection`)
      #   on all the agent hosts,
      # - Put a teardown step in place so that this package is uninstalled after the test,
      # - Run a default manifest on all the agent hosts, and
      # - Allow for assertions inside in a block
      #
      # @param [String] initial_package_version_or_collection Either a version
      #   of puppet-agent or the name of a puppet collection to install on agent hosts
      # @param [String] upgrade_manifest A manifest to apply to all agent nodes
      def run_foss_upgrade_with_manifest(initial_package_version_or_collection, upgrade_manifest)
        confine :except, platform: PE_ONLY_UPGRADES
        step "Prepare for FOSS upgrade" do
          prepare_upgrade_with(initial_package_version_or_collection)
        end
        step "Execute FOSS upgrade with default manifest:\n#{upgrade_manifest}" do
          with_default_site_pp(upgrade_manifest) do
            # Put your assertions here
            yield if block_given?
          end
        end
        teardown { purge_agents }
      end
    end
  end
end
