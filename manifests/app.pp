define unicorn::app (
    $approot,
    $unicorn_pidfile,
    $unicorn_socket,
    $config_template = 'unicorn/config_unicorn.config.rb.erb',
    $initscript      = "unicorn/init-unicorn.erb",
    $unicorn_backlog = '2048',
    $workers         = $::processorcount,
    $stdlog_path     = '',
    $log_stds        = 'false', # yes I know what it looks like.
    $unicorn_user    = 'root',
    $unicorn_group   = 'root',
    $config_file     = '',
    $rack_env        = 'production',
    $preload_app     = false,
  ) {

  # get the common stuff, like the unicorn package(s)
  require unicorn

  if "${log_stds}" in [ 'true', 'yes', 'present' ] {
    if $stdlog_path == '' {
      $unicorn_stdlog_path = "${approot}/log/"
    } else {
      $unicorn_stdlog_path = $stdlog_path
    }
    $unicorn_log_stdout = true  # easier than parsing it all in ERB
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

  service { "unicorn_${name}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    start      => "/etc/init.d/unicorn_${name} start",
    stop       => "/etc/init.d/unicorn_${name} stop",
    restart    => "/etc/init.d/unicorn_${name} reload",
    require    => [
      File["/etc/init.d/unicorn_${name}"],
      File["/etc/default/unicorn_${name}"],
    ],
  }

  file {
    "/etc/default/unicorn_${name}":
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("unicorn/default-unicorn.erb"),
      notify  => Service["unicorn_${name}"];
    "/etc/init.d/unicorn_${name}":
      owner   => root,
      group   => root,
      mode    => 755,
      content => template($initscript),
      notify  => Service["unicorn_${name}"];
    $config:
      owner   => root,
      group   => root,
      mode    => 644,
      content => template($config_template),
      notify  => Service["unicorn_${name}"];
  }
}
