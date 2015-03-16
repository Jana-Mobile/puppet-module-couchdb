 class couchdb::package::build {

  anchor { '::couchdb::package::build::start': }

  class { '::couchdb::package::dependencies': }

  exec { 'download':
    cwd     => $couchdb::cwd,
    command => "/usr/bin/wget -q ${couchdb::download} -O ${couchdb::filename}",
    timeout => '120',
  }

  exec { 'extract':
    cwd     => $couchdb::cwd,
    command => "/bin/tar -xzvf ${couchdb::filename}",
    timeout => '120',
  }

  exec { 'configure':
    cwd         => "${couchdb::cwd}/${couchdb::foldername}",
    environment => 'HOME=/root',
    command     => "${couchdb::cwd}/${couchdb::foldername}/configure ${couchdb::package::buildoptions}",
    timeout     => '600',
  }

  exec { 'make-install':
    cwd         => "${couchdb::cwd}/${couchdb::foldername}",
    environment => 'HOME=/root',
    command     => '/usr/bin/make && /usr/bin/make install',
    timeout     => '600',
  }

  anchor { '::couchdb::package::build::end': }

  Anchor['::couchdb::package::build::start'] ->
  Class['::couchdb::package::dependencies'] ->
  Exec['download'] ->
  Exec['extract'] ->
  Exec['configure'] ->
  Exec['make-install'] ->
  Anchor['::couchdb::package::build::end']

}
