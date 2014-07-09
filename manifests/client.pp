# Install client cli tool. See README.md for more details.
class postgresql::client (
  $package_name         = $postgresql::params::client_package_name,
  $package_ensure       = 'present',
  $manage_package_repo  = $postgresql::globals::manage_package_repo
) inherits postgresql::params {
  validate_string($package_name)

  # Setup the repo
  if $manage_package_repo {
    include postgresql::repo
  }

  package { 'postgresql-client':
    ensure  => $package_ensure,
    name    => $package_name,
    tag     => 'postgresql',
    require => $manage_package_repo ? {
      true    => Class['postgresql::repo'],
      default => undef,
    },
  }

  $file_ensure = $package_ensure ? {
    'present' => 'file',
    true      => 'file',
    'absent'  => 'absent',
    false     => 'absent',
    default   => 'file',
  }
  file { "/usr/local/bin/validate_postgresql_connection.sh":
    ensure => $file_ensure,
    source => "puppet:///modules/postgresql/validate_postgresql_connection.sh",
    owner  => 0,
    group  => 0,
    mode   => 0755,
  }

}
