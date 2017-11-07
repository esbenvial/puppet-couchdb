class { 'couchdb':
  bind_address   => '0.0.0.0',
  admin_password => 'asdf1234',
  http_secret    => '8bb8f92c2ea0431d6d974473bb4a11d1',
}
