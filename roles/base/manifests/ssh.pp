class base::ssh {
  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'PubkeyAuthentication'   => 'yes',
      'RSAAuthentication'      => 'yes',
      'PermitRootLogin'        => 'yes',
      'PasswordAuthentication' => 'no',
      'authorizedkeysfile'     => '.ssh/authorized_keys',
      'Port'                   => [22],
    }
  }
}
