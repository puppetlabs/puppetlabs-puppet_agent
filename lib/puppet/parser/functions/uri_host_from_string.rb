require 'uri'

module Puppet::Parser::Functions
  newfunction(:uri_host_from_string, :arity => 1, :type => :rvalue, :doc => <<-EOS
  Return a uri host from a string
  EOS
  ) do |args|

    uri = URI(args[0])

    return uri.host
  end
end

