# An enumerated list of settings which are permitted to be managed by this
# module.
type Puppet_agent::Config_setting = Enum[
  environment,
  http_connect_timeout,
  http_read_timeout,
  log_level,
  runinterval,
  show_diff,
  splay,
  splaylimit,
  usecacheonfailure,
]
