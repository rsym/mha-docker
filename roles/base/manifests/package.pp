class base::package {
  package {
    [
      'crontabs',
      'openssh-clients',
      'wget',
      'unzip',
    ]:
    ensure => present,
  }
}
