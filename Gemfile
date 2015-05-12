source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", :git => 'https://github.com/puppetlabs/puppet.git', :tag => ENV['PUPPET_VERSION'] || '3.8.0'
  gem "rspec", '< 3.2.0'
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
end
