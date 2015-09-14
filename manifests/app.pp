define unicorn::app (
  $approot,
  $pidfile,
  $socket,
  $gem_home,
  $export_home     = '',
  $backlog         = '2048',
  $workers         = $::processorcount,
  $user            = 'root',
  $group           = '0',
  $config_file     = '',
  $config_template = 'unicorn/config_unicorn.config.rb.erb',
  $initscript      = undef,
  $init_time       = 15,
  $logdir          = "${approot}/log",
  $rack_env        = 'production',
  $preload_app     = false,
  $source          = 'system',
  $logrotate       = false,
) {

  #require unicorn
  include unicorn::params

  $rc_d            = $unicorn::params::rc_d
  $real_initscript = pick($initscript, $unicorn::params::initscript)

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

  #$unicorn_opts = "--daemonize --env ${rack_env} --config-file ${config}"
  # XXX Debian Wheezy specific
  case $source {
    'system': {
      $daemon      = $unicorn::params::unicorn_executable
      #$daemon_opts = $unicorn_opts
    }
    'bundler': {
      $daemon      = $unicorn::params::bundler_executable
      #$daemon_opts = "exec unicorn ${unicorn_opts}"
    }
    /\/bin\/unicorn$/: {
      $daemon      = $source
      #$daemon_opts = $unicorn_opts
    }
    default: {
      fail("unicorn::app can't handle daemon source '${source}'")
    }
  }

  service { "unicorn_${name}":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    start     => "${rc_d}/unicorn_${name} start",
    stop      => "${rc_d}/unicorn_${name} stop",
    restart   => "${rc_d}/unicorn_${name} reload",
    require   => File["${rc_d}/unicorn_${name}"],
  }

  if $unicorn::params::etc_default {
    file { "/etc/default/unicorn_${name}":
      owner   => 'root',
      group   => '0',
      mode    => '0644',
      content => template('unicorn/default-unicorn.erb'),
      notify  => Service["unicorn_${name}"],
      before  => Service["unicorn_${name}"],
    }
  }

  file { "${rc_d}/unicorn_${name}":
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template($real_initscript),
    notify  => Service["unicorn_${name}"],
  }

  file { $config:
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template($config_template),
    notify  => Service["unicorn_${name}"];
  }

  if $logrotate {
    file { "/etc/logrotate.d/unicorn_${name}":
      ensure   => file,
      content  => template('logrotate.erb'),
      mode     => '0644',
      owner    => root,
      group    => root;
    }
  }
}
