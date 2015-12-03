source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'rake', '~> 10.4'
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.8'
  gem 'rspec', '< 3.2.0' # https://github.com/rspec/rspec-core/issues/1864
  gem 'rspec-puppet', '~> 2.2'
  gem 'puppetlabs_spec_helper', '~> 0.10'
  gem 'metadata-json-lint', '~> 0.0'
  gem 'rspec-puppet-facts', '~> 0.10'
end

group :system_tests do
  gem 'beaker', '~> 2.16'
  gem 'beaker-rspec', '~> 5.1'
end
