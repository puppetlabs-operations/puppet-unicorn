class unicorn($provider = 'gem', $ensure = 'present') {

  # The unicorn gem has prerequisites that requires building native extensions.
  require ruby::dev
  include rack

  package { 'unicorn':
    ensure   => $ensure,
    provider => $provider,
  }
}
