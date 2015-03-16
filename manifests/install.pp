class couchdb::install {

  if versioncmp($couchdb::foldername, 'apache-couchdb-1.2.0') >= 0 {
    $version = '1.2'
  }

  if $::couchdb::use_package == true {
    $couch_prefix = ''
    $logrotate_files = ["/etc/logrotate.d/couchdb"]
  } else {
    $couch_prefix = '/usr/local'
    $logrotate_files = ["${couch_prefix}/etc/logrotate.d/couchdb", "/etc/logrotate.d/couchdb"]
  }

  Exec {
    unless => "/usr/bin/test -f ${couch_prefix}/bin/couchdb",
  }

  user { 'couchdb':
    ensure      => present,
    home        => "${couch_prefix}/var/lib/couchdb",
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
    [$couchdb::database_dir, "${couch_prefix}/etc/couchdb",
    "${couch_prefix}/var/log/couchdb", "${couch_prefix}/var/run/couchdb"]:
    ensure  => directory,
  }

  file { "${couch_prefix}/etc/couchdb/local.ini":
    ensure  => file,
    mode    => '0600',
    content => template('couchdb/usr/local/etc/couchdb/local.ini.erb'),
    notify  => Service['couchdb'];
  }

  if $::couch::use_package == false {
    file { '/etc/init.d/couchdb':
      ensure  => link,
      target  => "${couch_prefix}/etc/init.d/couchdb",
    }
  }


  file { $logrotate_files:
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
