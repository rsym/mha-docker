class masterha::mha_manager (
  String $version,
  String $node_version,
  String $script_ensure,
  String $ssh_user,
) {
  class { 'mha::manager':
    version       => $version,
    node_version  => $node_version,
    script_ensure => $script_ensure,
    ssh_user      => $ssh_user,
  }
}
