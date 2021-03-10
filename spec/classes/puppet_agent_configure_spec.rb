# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_agent::configure' do
  let(:pre_condition) do
    [ 'function assert_private() { }',
      'class puppet_agent::params { $config = "/etc/puppetlabs/puppet/puppet.conf" }',
      'class puppet_agent { $config = $::test_config }',
      'include puppet_agent::params',
      'include puppet_agent',
    ]
  end

  context 'with empty config input' do
    let(:node_params) do
      { 'test_config' => [ ] }
    end

    it { is_expected.to compile }
  end

  context 'with settings input' do
    let(:node_params) do
      # Ensure this value matches something that's tested for in
      # spec/type_aliases/config_spec.rb. It can't be checked here directly
      # because loading the Puppet_agent::Config type alias would cause
      # conflicts with our mocking of the puppet_agent class.
      { 'test_config' => [{ "section" => "agent",
                            "setting" => "runinterval",
                            "value"   => "30m",
                            "ensure"  => "present" },
                          { "section" => "agent",
                            "setting" => "environment",
                            "ensure"  => "absent"}]}
    end

    it { is_expected.to contain_ini_setting('puppet-agent-runinterval')
                    .with({'section' => 'agent',
                           'setting' => 'runinterval',
                           'value'   => '30m',
                           'ensure'  => 'present'}) }
    it { is_expected.to contain_ini_setting('puppet-agent-environment')
                    .with({'section' => 'agent',
                           'setting' => 'environment',
                           'ensure'  => 'absent'}) }
  end
end
