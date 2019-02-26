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
    # When the MSI installargs parameter is passed to the powershell script it's inside
    # a cmd.exe instance, so we need to escape the quotes correctly so they show up as
    # plaintext double quotes to the powershell command. (To correctly escape to a
    # plaintext " you use three "'s in cmd.exe)
    return arg_string.join(' ').gsub('"', '"""')
  end
end
