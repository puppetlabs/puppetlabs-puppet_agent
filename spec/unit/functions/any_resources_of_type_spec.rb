require 'spec_helper'
require 'puppet/pops'
require 'puppet/loaders'

describe "the 'any_resources_of_type' function" do
  # rubocop:disable RSpec/BeforeAfterAll
  after(:all) { Puppet::Pops::Loaders.clear }
  # rubocop:enable RSpec/BeforeAfterAll

  # This loads the function once and makes it easy to call it
  # It does not matter that it is not bound to the env used later since the function
  # looks up everything via the scope that is given to it.
  # The individual tests needs to have a fresh env/catalog set up
  #
  let(:loaders) { Puppet::Pops::Loaders.new(Puppet::Node::Environment.create(:testing, [File.expand_path(fixtures('modules'))])) }
  let(:func) { loaders.private_environment_loader.load(:function, 'any_resources_of_type') }

  # A fresh environment is needed for each test since tests create resources
  let(:environment) { Puppet::Node::Environment.create(:testing, [File.expand_path(fixtures('modules'))]) }
  let(:node) { Puppet::Node.new('yaynode', environment: environment) }
  let(:compiler) { Puppet::Parser::Compiler.new(node) }
  let(:scope) { Puppet::Parser::Scope.new(compiler) }

  def newresource(type, title, parameters = {})
    resource = Puppet::Resource.new(type, title, parameters: parameters)
    compiler.add_resource(scope, resource)
    resource
  end

  it 'raises if called without the "resource_type" argument' do
    expect { func.call(scope) }.to raise_error(ArgumentError, %r{expects between.*got none})
  end

  it 'allows an optional "parameters" argument' do
    expect { func.call(scope, 'title', { param1: 'value1' }) }.not_to raise_error
  end

  it 'raises if the "parameters" argument is not a hash' do
    expect { func.call(scope, 'title', 'not_a_hash') }.to raise_error(ArgumentError, %r{parameter 'parameters' expects a Hash value, got String})
  end

  context 'when resources are defined' do
    context 'when there are multiple resources' do
      it 'iterates until a parameter matches' do
        newresource('filebucket', 'bucket_1')
        newresource('filebucket', 'bucket_2')
        newresource('filebucket', 'bucket_3')
        expect(func.call(scope, 'filebucket', name: 'bucket_3')).to be_truthy
      end
    end

    it 'finds by type name' do
      newresource('filebucket', 'my_filebucket')
      expect(func.call(scope, 'filebucket')).to be_truthy
    end

    it 'finds by capitalized type name' do
      newresource('filebucket', 'my_filebucket')
      expect(func.call(scope, 'Filebucket')).to be_truthy
    end

    it 'finds by type name and a parameter' do
      newresource('filebucket', 'my_filebucket')
      expect(func.call(scope, 'filebucket', name: 'my_filebucket')).to be_truthy
    end

    it 'finds by type name and multiple parameters' do
      newresource('filebucket', 'my_filebucket', path: false)
      expect(func.call(scope, 'filebucket', name: 'my_filebucket', path: false)).to be_truthy
    end

    it 'finds by type name and multiple parameters in any order' do
      newresource('filebucket', 'my_filebucket', path: false)
      expect(func.call(scope, 'filebucket', path: false, name: 'my_filebucket')).to be_truthy
    end
  end

  context 'when no resources are defined' do
    it 'does not find by type name' do
      expect(func.call(scope, 'filebucket')).to be_falsey
    end

    it 'matches the type but not the parameters' do
      newresource 'filebucket', 'my_filebucket'
      expect(func.call(scope, 'filebucket', name: 'not_my_filebucket')).to be_falsey
    end

    it 'matches the type but not all parameters' do
      newresource 'filebucket', 'my_filebucket', path: false
      expect(func.call(scope, 'filebucket', name: 'my_filebucket', path: '/path/to/bucket')).to be_falsey
    end
  end
end
