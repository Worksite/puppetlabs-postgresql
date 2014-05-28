# == Class: postgresql::server::tablespaces
#
# Creates PostgreSQL Tablespaces
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  tablespaces - A hash of tablespaces in postgresql::server::tablespace define format
#  hieramerge - enables hiera merging
#
class postgresql::server::tablespaces(

  $tablespaces  = $::postgresql::server::tablespaces,
  $hieramerge   = $::postgresql::server::hieramerge

) {

  # Load any Hiera based tablespaces (if enabled and present)
  #
  # NOTE: hiera hash merging does not work in a parameterized class
  #   definition; so we call it here.
  #
  # http://docs.puppetlabs.com/hiera/1/puppet.html#limitations
  # https://tickets.puppetlabs.com/browse/HI-118
  #
  if $hieramerge {
    $x_tablespaces = hiera_hash('postgresql::server::tablespaces', $tablespaces)
  } else {
    $x_tablespaces = $tablespaces
  }

  if ! empty($x_tablespaces) {
    create_resources('::postgresql::server::tablespace', $x_tablespaces)
  }

}

