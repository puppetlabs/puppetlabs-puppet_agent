{
  pre_suite: 'pre_suite',
  tests: 'tests',

  # Ensure the defaults are correct; we can't trust beaker to get this right.
  # Most of these are defaults that stop beaker from expecting/trying to use puppet 3:

  type: 'aio', # this is a FOSS install; Note that beaker considers the 'foss' type to be FOSS puppet 3. AIO is FOSS puppet 4+.
  'is_puppetserver': true,
  'use-service': true,
  'puppetservice': 'puppetserver',
  'puppetserver-confdir': '/etc/puppetlabs/puppetserver/conf.d',
  'puppetserver-config':'/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf'
}
