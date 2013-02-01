class unicorn::params {

  case $lsbmajdistrelease {
    '6': {
      $unicorn_executable = "/var/lib/gems/1.8/bin/unicorn"
      $bundler_executable = "/var/lib/gems/1.8/bin/bundle"
    }
    default: {
      $unicorn_executable = "/usr/local/bin/unicorn"
      $bundler_executable = "/usr/local/bin/bundle"
    }
  }
}
