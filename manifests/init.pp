class couchdb (
  $admin_name                 = 'admin',
  $admin_password             = 'admin',
  $http_secret                = '8bb8f92c2ea0431d6d974473bb4a11d1',
  $allow_jsonp                = false,
  $authentication_handlers    = '{couch_httpd_oauth, oauth_authentication_handler}, {couch_httpd_auth, cookie_authentication_handler}, {couch_httpd_auth, default_authentication_handler}',
  $bind_address               = '127.0.0.1',
  $couchdb_conf_dir           = '/opt/couchdb/etc',
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

  apt::source { 'couchdb':
    location => 'https://apache.bintray.com/couchdb-deb',
    repos    => 'main',
    #pin      => '-10',
    key      => {
      'id'     => '15866BAFD9BCC4F3C1E0DFC7D69548E1C17EAB57',
      'source' => 'https://couchdb.apache.org/repo/bintray-pubkey.asc',
    },
    include  => {
      'deb' => true,
    },
  }

  package { 'couchdb':
    ensure => present,
    require => Apt::Source['couchdb'],
  }

  File {
    owner => 'couchdb',
    group => 'couchdb',
    mode  => '0640',
  }

  file { 'uuid.ini':
    ensure => present,
    path   => "${couchdb_conf_dir}/local.d/uuid.ini",
    require => Package['couchdb'],
  }

  $default_dir = "${couchdb_conf_dir}/default.d"
  $local_dir   = "${couchdb_conf_dir}/local.d"

  Ini_Setting {
    ensure  => present,
    notify  => Service['couchdb'],
    require => Package['couchdb'],
  }

  ini_setting { 'couchdb-${default_dir}-chttpd-bind_address':
    path    => "${default_dir}/10-bind-address.ini",
    section => 'chttpd',
    setting => 'bind_address',
    value   => $bind_address,
  }

  ini_setting { 'couchdb-${local_dir}-admins-admin':
    path    => "${local_dir}/10-admins.ini",
    section => 'admins',
    setting => $admin_name,
    value   => $admin_password,
  }

  ini_setting { 'couchdb-${local_dir}-couch_httpd_auth-secret':
    path    => "${local_dir}/10-admins.ini",
    section => 'couch_httpd_auth',
    setting => 'secret',
    value   => $http_secret,
  }

  file { "${default_dir}/10-bind-address.ini":
    require => [
      Ini_setting['couchdb-${default_dir}-chttpd-bind_address'],
    ],
  }
  file { "${local_dir}/10-admins.ini":
    require => [
      Ini_setting['couchdb-${local_dir}-couch_httpd_auth-secret'],
      Ini_setting['couchdb-${local_dir}-admins-admin'],
    ],
  }

  service { 'couchdb':
    ensure => running,
    enable => true,
  }
}
