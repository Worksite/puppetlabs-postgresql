# == Class: postgresql::server::grants
#
# Manages PostgreSQL database and table grants
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  database_grants - A hash of databases grants in postgresql::server::database_grant define format
#  table_grants - A hash of database table grants in postgresql::server::table_grant define format
#  hieramerge - enables hiera merging
#
class postgresql::server::grants(

  $database_grants  = $::postgresql::server::database_grants,
  $table_grants     = $::postgresql::server::table_grants,
  $hieramerge       = $::postgresql::server::hieramerge

) {

  # Load any Hiera based grants (if enabled and present)
  #
  # NOTE: hiera hash merging does not work in a parameterized class
  #   definition; so we call it here.
  #
  # http://docs.puppetlabs.com/hiera/1/puppet.html#limitations
  # https://tickets.puppetlabs.com/browse/HI-118
  #
  if $hieramerge {
    $x_database_grants  = hiera_hash('postgresql::server::database_grants', $database_grants)
    $x_table_grants     = hiera_hash('postgresql::server::table_grants', $table_grants)
  } else {
    $x_database_grants  = $database_grants
    $x_table_grants     = $table_grants
  }

  if ! empty($x_database_grants) {
    create_resources('::postgresql::server::database_grant', $x_database_grants)
  }

  if ! empty($x_table_grants) {
    create_resources('::postgresql::server::table_grant', $x_table_grants)
  }

}

