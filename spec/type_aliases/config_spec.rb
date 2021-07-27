require 'spec_helper'

describe 'Puppet_agent::Config' do
  it { is_expected.to allow_values({ "section" => "agent",
                                     "setting" => "runinterval",
                                     "value"   => "30m",
                                     "ensure"  => "present" },
                                   { "section" => "agent",
                                     "setting" => "environment",
                                     "ensure"  => "absent"})}
end
