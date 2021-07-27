class puppet_agent::configure {
  assert_private()

  $puppet_agent::config.each |$item| {
    $ensure = $item['ensure'] ? {
      undef   => present,
      default => $item['ensure'],
    }

    ini_setting { "puppet-${item['section']}-${item['setting']}":
      ensure  => $ensure,
      section => $item['section'],
      setting => $item['setting'],
      value   => $item['value'],
      path    => $puppet_agent::params::config,
    }
  }

}
