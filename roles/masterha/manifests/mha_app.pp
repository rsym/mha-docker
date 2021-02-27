class masterha::mha_app (
  Tuple   $nodes,
  String  $user,
  String  $password,
  String  $repl_user,
  String  $repl_password,
  String  $ssh_user,
  String  $ssh_private_key_filename,
  String  $ssh_private_key,
  Boolean $manage_daemon
) {
  if $ssh_user == 'root' {
    $ssh_dir = '/root/.ssh'
  } else {
    $ssh_dir = "/home/$ssh_user/.ssh"
  }
  $ssh_key_path = "$ssh_dir/$ssh_private_key_filename"

  file { $ssh_dir:
    ensure => directory,
    mode   => '0600',
    owner  => $ssh_user,
  }

  mha::manager::app { 'mha_app':
    nodes           => $nodes,
    user            => $user,
    password        => $password,
    repl_user       => $repl_user,
    repl_password   => $repl_password,
    ssh_key_path    => $ssh_key_path,
    ssh_user        => $ssh_user,
    ssh_private_key => $ssh_private_key,
    manage_daemon   => $manage_daemon,
  }
}

