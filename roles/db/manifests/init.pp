class db {
  include 'db::mysql_server'
  include 'db::mha_node'
  include 'db::restore_db'

  Class['db::mysql_server']
  -> Class['db::mha_node']
  -> Class['db::restore_db']
}
