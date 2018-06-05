#! /opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'puppet/face'
require 'json'

# Read all the settings
Puppet.initialize_settings

# This stops the following error:
# "Bad Request: The environment must be purely alphanumeric, not '*root*'
Puppet::ApplicationSupport.push_application_context(Puppet::Util::RunMode[:user], :not_required)

result = {}

# Get the face
facts = Puppet::Face.face?(:facts,:current)

# Only try to upload the facts if the face exists
if facts
  # Maybe we should add error handling here, for now I'm just going to let it
  # fail if it fails as PXP will pick up the exception anyway
  if facts.respond_to? :upload
    facts.upload
    result['status']  = 'complete'
    result['message'] = 'Facts uploaded'
  else
    result['status']  = 'skipped'
    result['message'] = 'This agent does not have the "upload" action, possibly it is an old version. `puppet facts upload` was added in Puppet 5.5.0'
  end
else
  result['status']  = 'skipped'
  result['message'] = 'This agent does not have the "facts" face, possibly it is an old version. `puppet facts upload` was added in Puppet 5.5.0'
end


puts result.to_json
