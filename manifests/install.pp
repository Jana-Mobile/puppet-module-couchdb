class couchdb::install {

  if versioncmp($couchdb::foldername, 'apache-couchdb-1.2.0') >= 0 {
    $version = '1.2'
  }

  Exec {
    unless => '/usr/bin/test -f /usr/local/bin/couchdb',
  }

  user { 'couchdb':
    ensure      => present,
    home        => '/usr/local/var/lib/couchdb',
    managehome  => false,
    comment     => 'CouchDB Administrator',
    shell       => '/bin/bash'
  }

  File {
    owner   => 'couchdb',
    group   => 'couchdb',
    mode    => '0700',
    require => [
      User['couchdb']
    ],
  }

  file {
    [$couchdb::database_dir, '/usr/local/etc/couchdb',
    '/usr/local/var/log/couchdb', '/usr/local/var/run/couchdb']:
    ensure  => directory,
  }

  file { '/usr/local/etc/couchdb/local.ini':
    ensure  => file,
    mode    => '0600',
    content => template('couchdb/usr/local/etc/couchdb/local.ini.erb'),
    notify  => Service['couchdb'];
  }

  file { '/etc/init.d/couchdb':
    ensure  => link,
    target  => '/usr/local/etc/init.d/couchdb',
  }

  file { ['/usr/local/etc/logrotate.d/couchdb', '/etc/logrotate.d/couchdb']:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('couchdb/usr/local/etc/logrotate.d/couchdb.erb'),
  }

  file { '/etc/security/limits.d/100-couchdb.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('couchdb/etc/security/limits.d/100-couchdb.conf.erb'),
  }

  # remove build folder
  case $couchdb::rm_build_folder {
    true: {
      notice('remove build folder')
      exec { 'remove-build-folder':
        cwd     => $couchdb::cwd,
        command => "/usr/bin/rm -rf ${couchdb::cwd}/${couchdb::foldername}",
        require => Exec['make-install'],
      }
    }
    default: {}
  }
}
