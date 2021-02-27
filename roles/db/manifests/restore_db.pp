class db::restore_db (
  String $ensure = 'absent',
  String $master_host = '',
  String $root_password = '',
  String $repl_user = '',
  String $repl_password = ''
) {
  if $ensure == 'present' {
    file { '/var/tmp/restore_db.sh':
      ensure  => 'file',
      mode    => '0744',
      owner   => 'root',
      group   => 'root',
      content => "#!/bin/bash
/usr/bin/wget https://downloads.mysql.com/docs/world.sql.gz -P /var/tmp
/usr/bin/zcat /var/tmp/world.sql.gz | /usr/bin/mysql -uroot -p${root_password}
  "
    }

    exec { 'restore_db':
      path    => '/usr/bin',
      command => '/var/tmp/restore_db.sh',
      unless  => 'mysql -e "SHOW DATABASES" | grep "world"',
      require => File['/var/tmp/restore_db.sh'],
    }
 
    if $master_host != $facts['networking']['ip'] {
      # サンプルDB worldをリストアするとmysql-bin.00003, pos732711になる
      exec { 'start_slave':
        path    => '/usr/bin',
        command => "mysql -uroot -p${root_password} -e \"CHANGE MASTER TO MASTER_HOST='${master_host}', MASTER_USER='${repl_user}', MASTER_PASSWORD='${repl_password}', MASTER_LOG_FILE='mysql-bin.000003', MASTER_LOG_POS=732711; START SLAVE; SET GLOBAL read_only=1;\"",
        unless  => "mysql -e 'SHOW SLAVE STATUS\G' | grep 'Slave_SQL_Running: Yes'",
        require => Exec['restore_db'],
      }
    }
  }
}
