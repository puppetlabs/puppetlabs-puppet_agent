#!/usr/bin/env ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require 'etc'
require 'open3'

# The HOME environment variable is important when invoking Puppet. If HOME is not
# already set, set it.
ENV['HOME'] ||= Etc.getpwuid.dir

class Run < TaskHelper
  def task(options: {}, **kwargs)
    cmd = []
    cmd << puppet_executable << 'agent'

    default_options = {
      'onetime'            => true,
      'verbose'            => true,
      'daemonize'          => false,
      'usecacheonfailure'  => false,
      'detailed-exitcodes' => true,
      'splay'              => false,
      'show_diff'          => true,
    }

    default_options.merge(options).each do |opt, val|
      case val
      when true
        cmd << "--#{opt}"
      when false
        cmd << "--no-#{opt}"
      else
        cmd << "--#{opt}" << val
      end
    end

    output, status = Open3.capture2e(*cmd)

    result = {
      output: output,
      exitcode: status.exitstatus,
      command: cmd.join(' ')
    }

    case status.exitstatus
    when 0, 2
      result
    when 4, 6
      raise TaskHelper::Error.new("Puppet agent run succeeded, but some resources failed",
                                  "puppet_agent/resource-error",
                                  result)
    else
      raise TaskHelper::Error.new("Puppet agent run failed or wasn't attempted",
                                  "puppet_agent/run-error",
                                  result)
    end
  end 

  def puppet_executable
    preferred = if windows?
                  'C:/Program Files/Puppet Labs/Puppet/bin/puppet.bat'
                else
                  '/opt/puppetlabs/bin/puppet'
                end

    # Invoke the preferred executable if it exists. Otherwise, expect/require
    # that puppet be in the PATH and can be invoked as "puppet".
    File.exist?(preferred) ? preferred : 'puppet'
  end

  def windows?
    # Ruby only sets File::ALT_SEPARATOR on Windows and the Ruby standard
    # library uses that to test what platform it's on. This method can be used
    # to determine the behavior of the underlying system without requiring
    # features to be initialized and without side effect.
    !!File::ALT_SEPARATOR
  end

end

if __FILE__ == $0
  Run.run
end
