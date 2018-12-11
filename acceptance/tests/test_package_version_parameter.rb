require 'beaker-puppet'
require_relative '../helpers'

# Tests an upgrade from one specific agent version to another.
# @example
#   FROM_AGENT_VERSION=6.0.1 TO_AGENT_VERSION=6.0.2 beaker exec ./tests/test_package_version_parameter.rb
test_name 'puppet_agent class: package_version parameter for FOSS upgrades' do
  confine :except, platform: PE_ONLY_PLATFORMS

  expect_environment_variables('FROM_AGENT_VERSION', 'TO_AGENT_VERSION')
  teardown { run_teardown }
  run_setup

  target_version = ENV['TO_AGENT_VERSION']

  manifest_content = <<-PP
  class { 'puppet_agent': package_version => '#{target_version}' }
PP

  agents_only.each do |agent|
    with_default_site_pp(manifest_content) do
      installed_version = puppet_agent_version_on(agent)
      assert_equal(target_version, installed_version,
                   "Expected puppet-agent version '#{target_version}' to be installed on #{agent} (#{agent['platform']}), but found '#{installed_version}'")
    end
  end
end
