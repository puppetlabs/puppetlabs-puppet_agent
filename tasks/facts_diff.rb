#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'json'
require 'puppet'

params = JSON.parse(STDIN.read)
exclude = params['exclude']
require_relative File.join(params['_installdir'], 'puppet_agent', 'files', 'rb_task_helper.rb')

# Task to run `puppet facts diff` command
module PuppetAgent
  class FactsDiff
    include PuppetAgent::RbTaskHelper

    def initialize(exclude)
      @exclude = exclude
    end

    def run
      unless puppet_bin_present?
        return error_result(
          'puppet_agent/no-puppet-bin-error',
          "Puppet executable '#{puppet_bin}' does not exist",
        )
      end

      unless suitable_puppet_version?
        return error_result(
          'puppet_agent/no-suitable-puppet-version',
          "puppet facts diff command is only available on puppet 6.x(>= 6.20.0), target has: #{Puppet.version}",
        )
      end

      if @exclude && !exclude_parameter_supported?
        return error_result(
          'puppet_agent/exclude-parameter-not-supported',
          "exclude parameter is only available on puppet >= 6.22.0, target has: #{Puppet.version}",
        )
      end

      options = {
        failonfail: true,
        override_locale: false
      }

      command = [puppet_bin, 'facts', 'diff']
      command << '--exclude' << "\"#{Regexp.new(@exclude)}\"" if @exclude && !@exclude.empty?

      run_result = Puppet::Util::Execution.execute(command, options)

      minified_run_result = run_result.delete("\n").delete(' ')
      minified_run_result == '{}' ? 'No differences found' : run_result
    end

    private

    def suitable_puppet_version?
      puppet_version = Puppet.version
      Puppet::Util::Package.versioncmp(puppet_version, '6.20.0') >= 0 &&
        Puppet::Util::Package.versioncmp(puppet_version, '7.0.0') < 0
    end

    def exclude_parameter_supported?
      puppet_version = Puppet.version
      Puppet::Util::Package.versioncmp(puppet_version, '6.22.0') >= 0 &&
        Puppet::Util::Package.versioncmp(puppet_version, '7.0.0') < 0
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  task = PuppetAgent::FactsDiff.new(exclude)
  puts task.run
end
