# == Class: postgresql::server::dbs
#
# Creates PostgreSQL databases, roles and assigns permissions
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  databases - A hash of databases in postgresql::server::db define format
#  hieramerge - enables hiera merging
#
class postgresql::server::dbs(

  $dbs        = $::postgresql::server::dbs,
  $hieramerge = $::postgresql::server::hieramerge

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
    $x_dbs = hiera_hash('postgresql::server::dbs', $dbs)
  } else {
    $x_dbs = $dbs
  }

  if ! empty($x_dbs) {
    create_resources('::postgresql::server::db', $x_dbs)
  }

}

