#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'json'
require 'puppet'

params = JSON.parse(STDIN.read)
force = params['force']
require_relative File.join(params['_installdir'], 'puppet_agent', 'files', 'rb_task_helper.rb')

# Task to delete local filebucket
class PuppetAgent::DeleteLocalFilebucket
  include PuppetAgent::RbTaskHelper

  def initialize(force)
    @force = force
  end

  def run
    unless puppet_bin_present?
      return error_result(
        'puppet_agent/no-puppet-bin-error',
        "Puppet executable '#{puppet_bin}' does not exist",
      )
    end

    begin
      path = clientbucketdir
      if path && !path.empty? && (File.directory?(path) || force)
        FileUtils.rm_r(Dir.glob("#{path}/*"), secure: true, force:)
        { "success": true }
      else
        error_result(
        'puppet_agent/cannot-remove-error',
        "clientbucketdir: '#{path}' does not exist or is not a directory",
      )
      end
    rescue StandardError => e
      error_result(
        'puppet_agent/cannot-remove-error',
        "#{e.class}: #{e.message}",
      )
    end
  end

  private

  def clientbucketdir
    options = {
      failonfail: false,
      override_locale: false,
    }

    command = "#{puppet_bin} config print clientbucketdir"
    Puppet::Util::Execution.execute(command, options).strip
  end

  attr_reader :force
end

if __FILE__ == $PROGRAM_NAME
  task = PuppetAgent::DeleteLocalFilebucket.new(force)
  puts task.run
end
