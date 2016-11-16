source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :development, :test do
  gem 'rake', '~> 10.4'
  gem 'puppet', ENV['PUPPET_GEM_VERSION'] || '~> 4'
  gem 'rspec', '< 3.2.0' # https://github.com/rspec/rspec-core/issues/1864
  gem 'rspec-puppet', '~> 2.2'
  gem 'puppetlabs_spec_helper', '~> 0.10'
  gem 'json_pure', '~> 1.8.3' # avoid version incompatible with Puppet 3.8
  gem 'json', '~> 1.8.3' # avoid trying to pull a newer version with Ruby 1.8.7
  gem 'metadata-json-lint', '~> 0.0'
  gem 'rspec-puppet-facts', '~> 1.3'
  gem 'semantic_puppet', '0.1.3'
  gem 'puppet-blacksmith', '>= 3.4.0', :require => false, :platforms => 'ruby' if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('1.9.3')
end

group :system_tests do
  gem 'beaker', '~> 2.16'
  gem 'beaker-rspec', '~> 5.1'
  gem 'beaker-hostgenerator'
end
