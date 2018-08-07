# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'install task' do

  # TODO: These tests should use beaker-task_helpers with BOLT-229
  def exec(command)
    stdout_str, _stderr, _status = Open3.capture3(*command)
    stdout_str
  end

  def make_inventory
    groups = []

    def add_node(node, group_name, groups)
      if group_name =~ /\A[a-z0-9_]+\Z/
        group = groups.find {|g| g[:name] == group_name}
        unless group
          group = { name: group_name, nodes: [] }
          groups << group
        end
        group[:nodes] << node
      else
        puts "Invalid group name #{group_name} skipping"
      end
    end

    nodes = hosts.map do |host|
      if host[:platform] =~ /windows/
        config = {
          transport: 'winrm',
          winrm: {
            user: host[:user],
            password: ENV['BEAKER_password'],
            ssl: false
          }
        }
        node = {
          name: host.hostname,
          config: config
        }
      else
        ssh = host[:ssh]
        if ssh
          config = { transport: 'ssh' , ssh: {} }
          [:password, :user, :port].each { |k| config[:ssh][k] = ssh[k] if ssh[k] }

          # This is required to find the key that may be loaded from config
          # The vagrant provisioner passes the vagrant ssh config instead of
          # specific options.
          key = nil
          keys = host.connection.instance_variable_get(:@ssh).options[:keys]
          key = keys.first if keys
          config[:ssh][:"private-key"] = key if key

          # If the hypevisor stores IP as part of its core config then hostname
          # is unlikely to resolve in beakers world, but there may be many hosts
          # on the same IP. Use a query argument to generate a unique hostname.
          # BOLT-510
          hostname = host.host_hash[:ip] ? "#{host.host_hash[:ip]}?n=#{host.hostname}" : host.hostname
          node_name = "ssh://#{hostname}"

          node = {
            name: node_name,
            config: config
          }
        else
          raise 'non-ssh targets not yet implemented'
        end
      end
      # Make alias groups for each role
      host[:roles].each do |role|
        add_node(node[:name], role, groups)
      end
      node
    end
    { nodes: nodes,
      groups: groups,
      config: {
        ssh: {
          'host-key-check' => false
        }
      }
    }
  end

  def run_task_on(target, task, **opts)
    result = bolt_on(target, 'task', 'run', task, opts)
    unless opts[:expect_success] == false
      expect_node_success(result)
    end
    result["items"]
  end

  def run_command_on(target, command, **opts)
    result = bolt_on(target, 'command', 'run', command, opts)
    unless opts[:expect_success] == false
      expect_node_success(result)
    end
    result["items"]
  end

  def expect_node_success(result)
    result['items'].each do |res|
      unless res['status'] == 'success'
        # We really need matchers for this. rspec is overabstracted
        useful_info = "#{res.dig('result', '_error','msg')} :\n #{res['result']['_output']}"
        expect(useful_info).to eq('')
      else
        expect(res['status']).to eq('success')
      end
    end

  end

  def module_path
    RSpec.configuration.module_path
  end

  # This is intended to be a general method to run bolt instead of beaker's 'on' helper. Long term configuration should be separated from
  def bolt_on(target, type, action, object,
              params: nil,
              flags: nil,
              expect_success: true)
    default_flags = {
      'host-key-check' => false,
    }
    # method will fail if these are overriden
    # THis should probably just be a validation thing?
    hard_flags = {
      'nodes' => target,
      'format' => 'json',
      'modulepath' => module_path,
    }
    hard_flags['params'] = params if params

    # We expect bolt to be installed inside the bundle
    # TODO: don't shell out
    command = ['bundle', 'exec', 'bolt', type, action]
    command << object if object

    default_flags.merge(flags || {} ).merge(hard_flags).each do |flag, val|
      if val.nil? || val == true
        command << "--#{flag}"
      elsif val == false
        command << "--no-#{flag}"
      elsif val.is_a?(String)
        command << "--#{flag}" << val
      else
        command << "--#{flag}" << val.to_json
      end
    end

    # TODO manage state better here
    # Should be able to pass BOLTDIR environment variable to easily ignore global state
    result = Dir.mktmpdir(nil) do |tmpd|
      inventory = make_inventory
      inventory_path = File.join(tmpd, 'inventory.yaml')
      config_path = File.join(tmpd, 'bolt.yaml')
      File.open(inventory_path, 'w') {|fh| fh.write(inventory.to_json)}
      File.open(config_path, 'w') {|fh| fh.write("---\n")}
      command += ['--inventoryfile', inventory_path]
      command += ['--configfile', config_path]
      exec(command)
    end

    begin
      result = JSON.parse(result)
    rescue JSON::ParserError
      raise "Got non-json result from bolt: #{result}"
    end

    if expect_success
      expect(result['_error']).to be_nil
    end
    result
  end

  it 'version returns null with no agent present' do
    results = run_task_on('target', 'puppet_agent::version')
    results.each do |res|
      expect(res['status']).to eq('success')
      expect(res['result']['version']).to eq(nil)
    end
  end

  it 'runs and installs the agent' do
    results = run_task_on('target', "puppet_agent::install")
    results.each do |res|
      expect(res["status"]).to eq("success")
    end
  end

  it 'vesion returns the version with agent present' do
    results = run_task_on('target', 'puppet_agent::version')
    results.each do |res|
      expect(res['status']).to eq('success')
      expect(res['result']['version']).to match(/^\d\.\d\.\d/)
      expect(res['result']['source']).to be
    end
  end
end