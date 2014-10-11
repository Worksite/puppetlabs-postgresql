# PRIVATE CLASS: do not use directly
class postgresql::repo (
  $ensure       = $postgresql::params::ensure,
  $version      = $postgresql::globals::globals_version,
  $yum_priority = $postgresql::params::yum_priority
) {
  case $::osfamily {
    'RedHat', 'Linux': {
      if $version == undef {
        fail("The parameter 'version' for 'postgresql::repo' is undefined. You must always define it when osfamily == Redhat or Linux")
      }

      if ($::operatingsystem == 'RedHat' and $::operatingsystemrelease =~ /^7/) {
        fail("RHEL 7 repo management is not yet supported")
      }

      class { 'postgresql::repo::yum_postgresql_org': }
    }

    'Debian': {
      class { 'postgresql::repo::apt_postgresql_org': }
    }

    default: {
      fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports managing repos for osfamily RedHat and Debian")
    }
  }
}
