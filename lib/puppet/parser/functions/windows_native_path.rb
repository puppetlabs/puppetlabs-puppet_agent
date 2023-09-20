module Puppet::Parser::Functions
  # @return Windows native path
  newfunction(:windows_native_path, arity: 1, type: :rvalue, doc: <<-EOS
  @return Return a windows native path
  EOS
  ) do |args|
    path = args[0]

    return path.gsub(%r{\/\s}, ' ').tr('/', '\\')
  end
end
