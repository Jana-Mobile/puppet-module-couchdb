class couchdb::package {

  if $::couchdb::use_package == true {
    package { 'couchdb':
      ensure => installed
    }
  } else {
    class { '::couchdb::package::build': }
  }

}
