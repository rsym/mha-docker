class db::mha_node (
  String $user,
  String $password,
  String $repl_user,
  String $repl_password,
  String $manager,
  Tuple  $nodes,
  String $ssh_key_type,
  String $ssh_public_key,
  String $ssh_private_key
) {

  class { '::mha::node':
    user            => $user,
    password        => $password,
    repl_user       => $repl_user,
    repl_password   => $repl_password,
    manager         => $manager,
    nodes           => $nodes,
    ssh_key_type    => $ssh_key_type,
    ssh_public_key  => $ssh_public_key,
    ssh_private_key => $ssh_private_key,
  }
}
