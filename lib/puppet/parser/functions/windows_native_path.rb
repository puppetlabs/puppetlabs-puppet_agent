module Puppet::Parser::Functions
  newfunction(:windows_native_path, :arity => 1, :type => :rvalue, :doc => <<-EOS
  Return a windows native path
  EOS
  ) do |args|

    path = args[0]

    return path.gsub(/\/\s/, ' ').gsub(/\//, "\\")
  end
end
