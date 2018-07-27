# frozen_string_literal: true

require 'puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

UNSUPPORTED_PLATFORMS = %w[Solaris AIX].freeze

base_dir = File.dirname(File.expand_path(__FILE__))

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # should we just use rspec_puppet
  c.add_setting :module_path
  c.module_path  = File.join(base_dir, 'fixtures', 'modules')

  # Configure all nodes in nodeset
  c.before :suite do
    #run_puppet_access_login(user: 'admin') if pe_install?
  end
end
