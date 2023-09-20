# @summary A function used to determine if there are any
# Puppet::Parser::Resource instances of the passed in resource type
Puppet::Functions.create_function(:any_resources_of_type, Puppet::Functions::InternalFunction) do
  # @return [Boolean] Whether there are any instances of resource_type
  # @param resource_type Resource type that is being looked for
  # @param parameters Optional parameters
  dispatch :any_resources_of_type do
    scope_param

    required_param 'String', :resource_type
    optional_param 'Hash[Any, Any]', :parameters
  end

  def any_resources_of_type(scope, resource_type, parameters = nil)
    scope.catalog.resources.any? do |resource|
      # We should always iterate over Puppet::Parser::Resource
      # instances here, and documentation states that types can be
      # strings or symbols.
      # https://www.rubydoc.info/gems/puppet/Puppet/Resource#initialize-instance_method
      if resource.type.to_s.casecmp(resource_type).zero? # String#casecmp? is Ruby 2.4+
        if parameters
          # If the resource matched, but any of the params didn't, go to the next one
          next if parameters.any? { |k, v| resource.to_hash[k.to_sym] != v }
        end
        true
      end
    end
  end
end
