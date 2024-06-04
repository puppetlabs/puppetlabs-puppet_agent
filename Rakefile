# frozen_string_literal: true

require 'bundler'
require 'puppet_litmus/rake_tasks' if Gem.loaded_specs.key? 'puppet_litmus'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-strings/tasks' if Gem.loaded_specs.key? 'puppet-strings'
require 'voxpupuli/acceptance/rake' if Gem.loaded_specs.key? 'voxpupuli-acceptance'

PuppetLint.configuration.send('disable_relative')
PuppetLint.configuration.send('disable_puppet_url_without_modules')
