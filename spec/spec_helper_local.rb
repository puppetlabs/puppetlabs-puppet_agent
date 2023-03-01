location = File.expand_path('/dev/null')

@default_module_facts = {
  aio_agent_version: '5.5.10',
  is_pe: false,
  fips_enabled: false,
  kernelmajversion: nil,
  os: {
    distro: {
      release: {
        full: nil,
      },
    },
    family: nil,
    name: nil,
    product: nil,
    release: {
      major: nil,
    },
    version: {
      major: nil,
    },
    windows: {
      system32: nil,
    },
  },
  path: nil,
  platform_tag: nil,
  puppet_agent_appdata: nil,
  puppet_client_datadir: nil,
  puppet_config: "#{location}/puppet.conf",
  puppet_master_server: nil,
  puppet_ssldir: "#{location}/ssl",
  puppet_sslpaths: {
    'privatedir' => {
      'path' => "#{location}/ssl/private",
      'path_exists' => true,
    },
    'privatekeydir' => {
      'path' => "#{location}/ssl/private_keys",
      'path_exists' => true,
    },
    'publickeydir' => {
      'path' => "#{location}/ssl/public_keys",
      'path_exists' => true,
    },
    'certdir' => {
      'path' => "#{location}/ssl/certs",
      'path_exists' => true,
    },
    'requestdir' => {
      'path' => "#{location}/ssl/certificate_requests",
      'path_exists' => true,
    },
    'hostcrl' => {
      'path' => "#{location}/ssl/crl.pem",
      'path_exists' => true,
    },
  },
  puppetversion: '5.5.10',
  ruby: {
    platform: nil,
  },
}

RSpec.configure do |c|
  c.before :each do
    Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue, doc: '') do |_args|
      '2018.1.0'
    end
  end
end

# Override facts
# Taken from: https://github.com/voxpupuli/voxpupuli-test/blob/master/lib/voxpupuli/test/facts.rb
#
# This doesn't use deep_merge because that's highly unpredictable. It can merge
# nested hashes in place, modifying the original. It's also unable to override
# true to false.
#
# A deep copy is obtained by using Marshal so it can be modified in place. Then
# it recursively overrides values. If the result is a hash, it's recursed into.
#
# A typical example:
#
# let(:facts) do
#   override_facts(super(), os: {'selinux' => {'enabled' => false}})
# end
def override_facts(base_facts, **overrides)
  facts = Marshal.load(Marshal.dump(base_facts))
  apply_overrides!(facts, overrides, false)
  facts
end

# A private helper to override_facts
def apply_overrides!(facts, overrides, enforce_strings)
  overrides.each do |key, value|
    # Nested facts are strings
    key = key.to_s if enforce_strings

    if value.is_a?(Hash)
      facts[key] = {} unless facts.key?(key)
      apply_overrides!(facts[key], value, true)
    else
      facts[key] = value
    end
  end
end
