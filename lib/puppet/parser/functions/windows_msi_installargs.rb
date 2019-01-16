module Puppet::Parser::Functions
  newfunction(:windows_msi_installargs, :arity => 1, :type => :rvalue, :doc => <<-EOS
  Return the $install_options parameter as a string usable in an msiexec command
  EOS
  ) do |args|

    install_args = args[0]

    arg_string = install_args.map do |option|
      if option.class == Hash
        key_value = option.shift
        "#{key_value[0]}=\"#{key_value[1]}\""
      else
        option
      end
    end
    return arg_string.join(' ')
  end
end
