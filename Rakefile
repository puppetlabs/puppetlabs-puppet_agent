# Enable future parser and disable stringify facts for specs
require 'puppet/version'
if Puppet.version.to_f < 4.0
  ENV['FUTURE_PARSER'] = 'yes'
  ENV['STRINGIFY_FACTS'] = 'no'
end

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f < 3.6
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('relative')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_single_quote_string_with_variables')
PuppetLint.configuration.send('disable_only_variable_string')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

PuppetSyntax.exclude_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc "Populate CONTRIBUTORS file"
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

task :metadata do
  sh "metadata-json-lint metadata.json"
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
  :metadata,
]
