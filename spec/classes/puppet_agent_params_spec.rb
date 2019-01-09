require 'spec_helper'

describe 'puppet_agent::params' do
  facts = {
    osfamily: 'Debian'
  }

  # rspec-puppet lets us query the compiled catalog only, so we can only check
  # if any specific resources have been declared. We cannot query for class
  # variables, so we cannot query for the collection variable's value. But we
  # can use a workaround by creating a notify resource whose message contains
  # the value and query that instead since it will be added as part of the
  # catalog. notify_resource tells rspec-puppet to include this resource only
  # after our class has been compiled, which is what we want.
  let(:notify_title) { "check puppet_agent::params::collection's value" }
  let(:post_condition) do
    <<-NOTIFY_RESOURCE
notify { "#{notify_title}":
  message => "${::puppet_agent::params::collection}"
}
    NOTIFY_RESOURCE
  end

  def sets_collection_to(collection)
    is_expected.to contain_notify(notify_title).with_message(collection)
  end

  context 'default puppet_collection value' do
    {
      '0.0.0'   => 'PC1',
      '1.10.14' => 'PC1',
      '3.2.1'   => 'PC1',
      '5.5.4'   => 'puppet5',
      '6.0.2'   => 'puppet6',
      '5.99.0'  => 'puppet6',
      '100.0.0' => 'puppet',
      ''        => 'PC1',
    }.each do |agent_version, default_collection|
      context "when puppet-agent version is '#{agent_version}'" do
        let(:facts) { facts.merge(aio_agent_version: agent_version) }
        it "the default collection is '#{default_collection}'" do
          sets_collection_to(default_collection)
        end
      end
    end
  end
end
