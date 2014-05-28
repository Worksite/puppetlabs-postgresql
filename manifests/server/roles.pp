# == Class: postgresql::server::roles
#
# Manages PostgreSQL database roles
# PRIVATE CLASS: do not call directly
#
# == Parameters
#
#  roles - A hash of database roles in postgresql::server::role define format
#  hieramerge - enables hiera merging
#
class postgresql::server::roles(

  $roles      = $::postgresql::server::roles,
  $hieramerge = $::postgresql::server::hieramerge

) {

  # Load any Hiera based database roles (if enabled and present)
  #
  # NOTE: hiera hash merging does not work in a parameterized class
  #   definition; so we call it here.
  #
  # http://docs.puppetlabs.com/hiera/1/puppet.html#limitations
  # https://tickets.puppetlabs.com/browse/HI-118
  #
  if $hieramerge {
    $x_roles = hiera_hash('postgresql::server::roles', $roles)
  } else {
    $x_roles = $roles
  }

  if ! empty($x_roles) {
    create_resources('::postgresql::server::role', $x_roles)
  }

}

