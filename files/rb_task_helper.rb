# frozen_string_literal: true

module PuppetAgent
  module RbTaskHelper
    private

    def error_result(error_type, error_message)
      {
        '_error' => {
          'msg' => error_message,
          'kind' => error_type,
          'details' => {},
        },
      }
    end

    def puppet_bin_present?
      File.exist?(puppet_bin)
    end

    # Returns the path to the Puppet agent executable
    def puppet_bin
      @puppet_bin ||= if Puppet.features.microsoft_windows?
                        puppet_bin_windows
                      else
                        '/opt/puppetlabs/bin/puppet'
                      end
    end

    # Returns the path to the Puppet agent executable on Windows
    def puppet_bin_windows
      require 'win32/registry'

      install_dir = begin
                      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Puppet Labs\Puppet') do |reg|
                        # Rescue missing key
                        dir = begin
                                reg['RememberedInstallDir64']
                              rescue StandardError
                                ''
                              end
                        # Both keys may exist, make sure the dir exists
                        break dir if File.exist?(dir)

                        # Rescue missing key
                        begin
                          reg['RememberedInstallDir']
                        rescue StandardError
                          ''
                        end
                      end
                    rescue Win32::Registry::Error
                      # Rescue missing registry path
                      ''
                    end

      File.join(install_dir, 'bin', 'puppet.bat')
    end
  end
end
