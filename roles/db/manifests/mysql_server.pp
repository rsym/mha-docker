class db::mysql_server (
  String  $package_ensure,
  String  $root_password,
  Boolean $manage_config_file,
  Boolean $remove_default_accounts,
  Boolean $restart,
  Any     $override_options
) {
  class { '::mysql::server':
    package_ensure          => $package_ensure,
    root_password           => $root_password,
    manage_config_file      => $manage_config_file,
    remove_default_accounts => $remove_default_accounts,
    restart                 => $restart,
    override_options        => $override_options,
  }
}
