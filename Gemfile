#This file is generated by ModuleSync, do not edit.

source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place.is_a?(String) && place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place.is_a?(String) && place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

# Used for gem conditionals
ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = "#{ruby_version_segments[0]}.#{ruby_version_segments[1]}"

# The following gems are not included by default as they require DevKit on Windows.
# You should probably include them in a Gemfile.local or a ~/.gemfile
#gem 'pry' #this may already be included in the gemfile
#gem 'pry-stack_explorer', :require => false
#if RUBY_VERSION =~ /^2/
#  gem 'pry-byebug'
#else
#  gem 'pry-debugger'
#end

group :development do
  gem "facterdb", '~> 1.4',                                  require: false
  gem "mocha", '~> 1.1',                                     require: false
  gem "parser", '~> 2.5',                                    require: false
  gem "puppet-syntax", '~> 2.6',                             require: false
  gem "specinfra", '2.82.2',                                 require: false
  gem "diff-lcs", '~> 1.3',                                  require: false
  gem "faraday", '~> 0.17',                                  require: false
  gem "pry-byebug", '~> 3.8',                                require: false
  gem "pry", '~> 0.10',                                      require: false
  gem "method_source", '~> 0.8',                             require: false
  gem "rake", '~> 12',                                       require: false
  gem "parallel_tests", '>= 2.14.1', '< 2.14.3',             require: false
  gem "metadata-json-lint", '>= 2.0.2', '< 3.0.0',           require: false
  gem "rspec-puppet-facts", '~> 2.0.1',                      require: false
  gem "rspec_junit_formatter", '~> 0.2',                     require: false
  gem "rubocop", '~> 0.49.0',                                require: false
  gem "rubocop-rspec", '~> 1.16.0',                          require: false
  gem "rubocop-i18n", '~> 1.2.0',                            require: false
  gem "puppetlabs_spec_helper", '>= 2.9.0', '< 3.0.0',       require: false
  gem "puppet-module-posix-default-r#{minor_version}",       require: false, platforms: "ruby"
  gem "puppet-module-win-default-r#{minor_version}",         require: false, platforms: ["mswin", "mingw", "x64_mingw"]
  gem "rspec-puppet",                                        require: true
  gem 'rspec-expectations', '~> 3.9.0',                      require: false
  gem "json_pure", '<= 2.0.1',                               require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.0.0')
  gem "fast_gettext", '1.1.0',                               require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.1.0')
  gem "fast_gettext",                                        require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.1.0')
  gem "puppet-lint", '2.3.6'
end

group :system_tests do
  gem "puppet-module-posix-system-r#{minor_version}", '~> 0.5',                  require: false, platforms: [:ruby]
  gem "puppet-module-win-system-r#{minor_version}", '~> 0.5',                    require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "beaker", *location_for(ENV['BEAKER_VERSION'] || '~> 4')
  gem "beaker-puppet", *location_for(ENV['BEAKER_PUPPET_VERSION'] || ["~> 1.0", ">= 1.0.1"])
  gem "beaker-docker", '~> 0.3'
  gem "beaker-vagrant", '~> 0.5'
  gem "beaker-vmpooler", '~> 1.3'
  gem "serverspec", '~> 2.39'
  gem "beaker-pe",                                                               :require => false
  gem "beaker-rspec", *location_for(ENV['BEAKER_RSPEC_VERSION'])
  gem "beaker-hostgenerator", *location_for(ENV['BEAKER_HOSTGENERATOR_VERSION'])
  gem "beaker-abs", *location_for(ENV['BEAKER_ABS_VERSION'] || '~> 0.1')
  # Bundler fails on 2.1.9 even though this group is excluded
  if ENV['GEM_BOLT']
    gem 'bolt', '~> 3.0', require: false
    gem 'beaker-task_helper', '~> 1.9', require: false
  end
end

group :release do
  gem 'pdk', *location_for(ENV['PDK_GEM_VERSION'] || '~> 2')
  gem "puppet-blacksmith", '~> 3.4',                                             require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.7.0')
  gem "puppet-blacksmith", '~> 6',                                               require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.7.0')
end

gem 'puppet', *location_for(ENV['PUPPET_GEM_VERSION'])

# Only explicitly specify Facter/Hiera if a version has been specified.
# Otherwise it can lead to strange bundler behavior. If you are seeing weird
# gem resolution behavior, try setting `DEBUG_RESOLVER` environment variable
# to `1` and then run bundle install.
gem 'facter', *location_for(ENV['FACTER_GEM_VERSION']) if ENV['FACTER_GEM_VERSION']
gem 'hiera', *location_for(ENV['HIERA_GEM_VERSION']) if ENV['HIERA_GEM_VERSION']

# Evaluate Gemfile.local if it exists
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exists?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end

# vim:ft=ruby
