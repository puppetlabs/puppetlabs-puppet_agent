# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_agent::configure' do
  let(:pre_condition) do
    [ 'function assert_private() { }',
      'class puppet_agent::params { $config = "/etc/puppetlabs/puppet/puppet.conf" }',
      'include puppet_agent::params',
      'include puppet_agent',
    ]
  end

  context 'with empty config input' do
    let(:pre_condition) do
      [ super(),
        'class puppet_agent { $config = [ ] }',
      ]
    end

    it { is_expected.to compile }
  end

  context 'with settings input' do
    let(:pre_condition) do
      [ super(),
        'class puppet_agent { $config = [{ "section" => "agent",
                                           "setting" => "runinterval",
                                           "value"   => "30m",
                                           "ensure"  => "present" }] }',
      ]
    end

    it { is_expected.to contain_ini_setting('puppet-agent-runinterval')
                    .with({'section' => 'agent',
                           'setting' => 'runinterval',
                           'value'   => '30m',
                           'ensure'  => 'present'}) }
  end
end
