define unicorn::app (
  $approot,
  $pidfile,
  $socket,
  $backlog         = '2048',
  $workers         = $::processorcount,
  $user            = 'root',
  $group           = '0',
  $config_file     = '',
  $config_template = 'unicorn/config_unicorn.config.rb.erb',
  $initscript      = 'unicorn/init-unicorn.erb',
  $logdir          = "${approot}/log",
  $rack_env        = 'production',
  $preload_app     = false,
  $source          = 'system',
) {

  require unicorn
  include unicorn::params

  $rc_d = $unicorn::params::rc_d

  if ! $rc_d {
    fail('unicorn is not supported on this platform')
  }

  # If we have been given a config path, use it, if not, make one up.
  # This _may_ not be the most secure, as it should live outside of
  # the approot unless it's almost going to be non $unicorn_user
  # writable.
  if $config_file == '' {
    $config = "${approot}/config/unicorn.config.rb"
  } else {
    $config = $config_file
  }

  $unicorn_opts = "-D -E ${rack_env} -c ${config}"
  # XXX Debian Wheezy specific
  case $source {
    'system': {
      $daemon      = $unicorn::params::unicorn_executable
      $daemon_opts = $unicorn_opts
    }
    'bundler': {
      $daemon      = $unicorn::params::bundler_executable
      $daemon_opts = "exec unicorn ${unicorn_opts}"
    }
    default: {
      fail("unicorn::app can't handle daemon source '${source}'")
    }
  }

  service { "unicorn_${name}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    start      => "${rc_d}/unicorn_${name} start",
    stop       => "${rc_d}/unicorn_${name} stop",
    restart    => "${rc_d}/unicorn_${name} reload",
    require    => [
      File["${rc_d}/unicorn_${name}"],
      File["/etc/default/unicorn_${name}"],
    ],
  }

  file { "/etc/default/unicorn_${name}":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('unicorn/default-unicorn.erb'),
    notify  => Service["unicorn_${name}"],
  }

  file { "${rc_d}/unicorn_${name}":
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template($initscript),
    notify  => Service["unicorn_${name}"],
  }

  file { $config:
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template($config_template),
    notify  => Service["unicorn_${name}"];
  }
}
