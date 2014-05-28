# == Class: postgresql::server::databases
#
# Creates PostgreSQL Databases
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  databases - A hash of databases in postgresql::server::database define format
#  hieramerge - enables hiera merging
#
class postgresql::server::databases(

  $databases    = $::postgresql::server::databases,
  $hieramerge   = $::postgresql::server::hieramerge

) {

  # Load any Hiera based databases (if enabled and present)
  #
  # NOTE: hiera hash merging does not work in a parameterized class
  #   definition; so we call it here.
  #
  # http://docs.puppetlabs.com/hiera/1/puppet.html#limitations
  # https://tickets.puppetlabs.com/browse/HI-118
  #
  if $hieramerge {
    $x_databases = hiera_hash('postgresql::server::databases', $databases)
  } else {
    $x_databases = $databases
  }

  if ! empty($x_databases) {
    create_resources('::postgresql::server::database', $x_databases)
  }

}

