# Define for creating a database. See README.md for more details.
define postgresql::server::database(
  $dbname     = $title,
  $owner      = $postgresql::server::user,
  $tablespace = undef,
  $template   = 'template0',
  $encoding   = $postgresql::server::encoding,
  $locale     = $postgresql::server::locale,
  $istemplate = false
) {
  $createdb_path = $postgresql::server::createdb_path
  $user          = $postgresql::server::user
  $group         = $postgresql::server::group
  $psql_path     = $postgresql::server::psql_path
  $port          = $postgresql::server::port
  $version       = $postgresql::server::version
  $default_db    = $postgresql::server::default_database

  # Set the defaults for the postgresql_psql resource
  Postgresql_psql {
    psql_user  => $user,
    psql_group => $group,
    psql_path  => $psql_path,
    port       => $port,
  }

  # Optionally set the locale switch. Older versions of createdb may not accept
  # --locale, so if the parameter is undefined its safer not to pass it.
  if ($version != '8.1') {
    $locale_option = $locale ? {
      undef   => '',
      default => "--locale=${locale} ",
    }
    $public_revoke_privilege = 'CONNECT'
  } else {
    $locale_option = ''
    $public_revoke_privilege = 'ALL'
  }

  $encoding_option = $encoding ? {
    undef   => '',
    default => "--encoding '${encoding}' ",
  }

  $tablespace_option = $tablespace ? {
    undef   => '',
    default => "--tablespace='${tablespace}' ",
  }

  $createdb_command = "${createdb_path} --port='${port}' --owner='${owner}' --template=${template} ${encoding_option}${locale_option}${tablespace_option} '${dbname}'"
  $revoke_sql = "REVOKE ${public_revoke_privilege} ON DATABASE \"${dbname}\" FROM public"
  $update_sql = "UPDATE pg_database SET datistemplate = ${istemplate} WHERE datname = '${dbname}'"

  ensure_resource('postgresql_psql', "Check for existence of db '${dbname}'", {
    'command' => 'SELECT 1',
    'unless'  => "SELECT datname FROM pg_database WHERE datname='${dbname}'",
    'db'      => $default_db,
    'port'    => $port,
    'require' => Class['postgresql::server::service'],
    'notify'  => Exec[$createdb_command],
  })

  ensure_resource('exec', $createdb_command, {
    'refreshonly' => true,
    'user'        => $user,
    'logoutput'   => on_failure,
    'notify'      => Postgresql_psql[$revoke_sql],
  })

  # This will prevent users from connecting to the database unless they've been
  #  granted privileges.
  ensure_resource('postgresql_psql', $revoke_sql, {
    'db'          => $default_db,
    'port'        => $port,
    'refreshonly' => true,
  })

  ensure_resource('postgresql_psql', $update_sql, {
    'unless'  => "SELECT datname FROM pg_database WHERE datname = '${dbname}' AND datistemplate = ${istemplate}",
    'db'      => $default_db,
    'require' => Exec[$createdb_command],
  })

  # Build up dependencies on tablespace
  if($tablespace != undef and defined(Postgresql::Server::Tablespace[$tablespace])) {
    Postgresql::Server::Tablespace[$tablespace]->Exec[$createdb_command]
  }
}
