class couchdb (
  $admin_name                 = 'admin',
  $admin_password             = 'admin',
  $allow_jsonp                = false,
  $authentication_handlers    = '{couch_httpd_oauth, oauth_authentication_handler}, {couch_httpd_auth, cookie_authentication_handler}, {couch_httpd_auth, default_authentication_handler}',
  $bind_address               = '127.0.0.1',
  $couchdb_conf_dir           = '/etc/couchdb',
  $database_dir               = '/var/lib/couchdb',
  $delayed_commits            = true,
  $default_handler            = '{couch_httpd_db, handle_request}',
  $document_size_unit         = 'bytes',
  $include_sasl               = true,
  $javascript                 = '/usr/bin/couchjs /usr/share/couchdb/server/main.js',
  $log_file                   = '/var/log/couchdb/couch.log',
  $log_level                  = 'info',
  $log_max_chunk_size         = '1000000',
  $max_attachment_chunk_size  = '4294967296 ;4GB',
  $max_connections            = '2048',
  $max_dbs_open               = '100',
  $max_document_size          = '4294967296',
  $os_process_timeout         = '5000 ; 5 seconds. for view and external servers.',
  $port                       = '5984',
  $reduce_limit               = true,
  $require_valid_user         = false,
  $secret                     = 'changeme',
  $secure_rewrites            = true,
  $service_enable             = true,
  $uri_file                   = '/var/lib/couchdb/couch.uri',
  $vhost_global_handlers      = '_utils, _uuids, _session, _oauth, _users',
  $view_index_dir             = '/var/lib/couchdb',
) {

  include ::apt

  apt::ppa { 'ppa:couchdb/stable': }

  package { 'couchdb':
    ensure => present,
    require => Apt::Ppa['ppa:couchdb/stable'],
  }

  file { 'uuid.ini':
    ensure => present,
    path   => "${couchdb_conf_dir}/local.d/uuid.ini"
  }

  $local_ini = "${couchdb_conf_dir}/local.ini"

  Ini_Setting {
    ensure  => present,
    path    => $local_ini,
  }

  ini_setting { 'couchdb-ini-bind_address':
    section => 'httpd',
    setting => 'bind_address',
    value   => $bind_address,
  }

  ini_setting { 'couchdb-ini-bind_address':
    ensure  => present,
    path    => $local_ini,
    section => 'admins',
    setting => $admin_name,
    value   => $admin_password,
  }
  ini_setting { 'couchdb-ini-ssl_certificate_max_depth':
    ensure  => present,
    path    => $local_ini,
    section => 'ssl',
    setting => 'ssl_certificate_max_depth',
    value   => 1,
  }
}
