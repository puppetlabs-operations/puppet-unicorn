class unicorn {

  # The unicorn gem has prerequisites that requires building native extensions.
  require ruby::dev

  package { 'unicorn': ensure => installed, provider => gem; }

}

