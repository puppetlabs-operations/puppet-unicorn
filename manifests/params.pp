class unicorn::params {

  case $::operatingsystem {
    'debian', 'ubuntu', 'centos': {
      case $::lsbmajdistrelease {
        '6': {
          $unicorn_executable = '/var/lib/gems/1.8/bin/unicorn'
          $bundler_executable = '/var/lib/gems/1.8/bin/bundle'
        }
        default: {
          $unicorn_executable = '/usr/local/bin/unicorn'
          $bundler_executable = '/usr/local/bin/bundle'
        }
      }
    }
    'ubuntu': {
      $unicorn_executable = '/usr/local/bin/unicorn'
      $bundler_executable = '/usr/local/bin/bundle'
    }

    'freebsd': {
      $unicorn_executable = '/usr/local/bin/unicorn'
      $bundler_executable = '/usr/local/bin/bundle'
    }

    'centos': {
      $unicorn_executable = '/usr/local/bin/unicorn'
      $bundler_executable = '/usr/local/bin/bundle'
    }
  }

  case $::kernel {
    'linux': {
      $rc_d        = '/etc/init.d'
      $etc_default = true
      $initscript  = 'unicorn/init-unicorn.erb'
    }
    'freebsd': {
      $rc_d        = '/usr/local/etc/rc.d'
      $etc_default = false
      $initscript  = 'unicorn/rc.d-unicorn.erb'
    }
  }
}
