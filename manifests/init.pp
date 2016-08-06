class unicorn (
  $export_home = '',
  $manage_package = true,
  $ensure   = 'present',
  $provider = 'gem',
) {
  if $manage_package {
    # The unicorn gem has prerequisites that requires building native extensions.
    require ::ruby::dev
    include ::rack

    package { 'unicorn':
      ensure   => $ensure,
      provider => $provider,
    }
  }
}
