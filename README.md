# mha-docker

MySQL MHAの検証ができる環境です。
環境の構築にはdockerとpuppetを使用しています。

## 初期セットアップ

### 1. git clone & 諸々のインストール

```
$ git clone git@github.com:rsym/mha-docker.git
$ bundle install --path vendor/bundle
$ bundle exec librarian-puppet install --path vendor/modules
```

### 2. eyaml用の鍵ペアを作成する

後述の手順で必要なeyaml用の鍵ペアを作成します。

```
$ bundle exec eyaml createkeys
[hiera-eyaml-core] Created key directory: ./keys
[hiera-eyaml-core] Keys created OK

$ ls keys
private_key.pkcs7.pem public_key.pkcs7.pem
```


### 3. `./hieradata/development_secret.yaml`の生成

`./hieradata/development_secret.yaml`というファイルを新規作成して以下を記述します。
本ファイルは`.gitignore`で構成管理対象から除外しています。

 - `root::ssh_public_key:`：rootユーザの公開鍵
 - `root::ssh_private_key:`：rootユーザの秘密鍵
 - `mysql_user::root::password:`：root(MySQLユーザ)のパスワード
 - `mysql_user::repl::password:`：replicator(MySQLユーザ)のパスワード
 - `mysql_user::mha::password:`：mha(MySQLユーザ)のパスワード

これを一つ一つ`eyaml encrypt`で暗号化して記述するのはだいぶ面倒です。
そこで、`./hieradata/development_secret.yaml`に記述する文字列を生成してくれるスクリプト`bin/generate_secret_yaml.sh`を使います。
本スクリプトを実行すると、ssh-keygenで生成した鍵と各MySQLのパスワードを暗号化したものを出力してくれます。
これを`./hieradata/development_secret.yaml`にペーストすればOKです。

デフォルトで生成される各ユーザのパスワードは`root-p@ssw0rd`/`repl-p@ssw0rd`/`mha-p@ssw0rd`となります。
```
$ sh bin/generate_secret_yaml.sh
---
root::ssh_public_key: ENC[PKCS7,MII ... BM=]
root::ssh_private_key: ENC[PKCS7,MII ... Q==]

mysql_user::root::password: ENC[PKCS7,MII ... /b+]
mysql_user::repl::password: ENC[PKCS7,MII ... LTq]
mysql_user::mha::password: ENC[PKCS7,MII ... U/g]


paste aboves to ./hieradata/${::environment}_secret.yaml

mysql_user::root::password is root-p@ssw0rd
mysql_user::repl::password is repl-p@ssw0rd
mysql_user::mha::password is mha-p@ssw0rd
```

別のパスワードを使用したい場合は、コマンド引数で指定してください。
```
$ sh bin/generate_secret_yaml.sh foo bar baz
---
root::ssh_public_key: ENC[PKCS7,MII ... lk=]
root::ssh_private_key: ENC[PKCS7,MII ... Q==]

mysql_user::root::password: ENC[PKCS7,MII ... ZAd]
mysql_user::repl::password: ENC[PKCS7,MII ... 6Cd]
mysql_user::mha::password: ENC[PKCS7,MII ... pJx]


paste aboves to ./hieradata/${::environment}_secret.yaml

mysql_user::root::password is foo
mysql_user::repl::password is bar
mysql_user::mha::password is baz
```

#### `./hieradata/development_secret.yaml`の記述例

```
$ cat hieradata/development_secret.yaml
---
root::ssh_public_key: ENC[PKCS7,MII ... BM=]
root::ssh_private_key: ENC[PKCS7,MII ... Q==]

mysql_user::root::password: ENC[PKCS7,MII ... /b+]
mysql_user::repl::password: ENC[PKCS7,MII ... LTq]
mysql_user::mha::password: ENC[PKCS7,MII ... U/g]
```

## 起動

`bin/setup.sh`を実行することで、コンテナの起動・マニフェストの適用・DBのリストア・MHAの起動がされます。
```
$ sh bin/setup.sh
```

### コンテナの一覧

セットアップ後は以下のコンテナが起動します。
```
$ docker-compose ps
    Name                  Command                  State                                       Ports
-------------------------------------------------------------------------------------------------------------------------------------
db001          /sbin/init                       Up             0.0.0.0:57402->22/tcp, 0.0.0.0:57398->3306/tcp,
                                                               0.0.0.0:57395->8301/tcp, 0.0.0.0:57393->8500/tcp,
                                                               0.0.0.0:57392->8600/tcp
db002          /sbin/init                       Up             0.0.0.0:57411->22/tcp, 0.0.0.0:57409->3306/tcp,
                                                               0.0.0.0:57406->8301/tcp, 0.0.0.0:57403->8500/tcp,
                                                               0.0.0.0:57399->8600/tcp
db003          /sbin/init                       Up             0.0.0.0:57410->22/tcp, 0.0.0.0:57408->3306/tcp,
                                                               0.0.0.0:57405->8301/tcp, 0.0.0.0:57401->8500/tcp,
                                                               0.0.0.0:57397->8600/tcp
masterha001    /sbin/init                       Up             0.0.0.0:57407->22/tcp, 0.0.0.0:57404->3306/tcp,
                                                               0.0.0.0:57400->8301/tcp, 0.0.0.0:57396->8500/tcp,
                                                               0.0.0.0:57394->8600/tcp
puppetserver   dumb-init /docker-entrypoi ...   Up (healthy)   0.0.0.0:57386->22/tcp, 0.0.0.0:57385->8140/tcp

```

#### db001/db002/db003

 - mariadbが動いています
 - デフォルトはdb001がmaster、db002,db003がslaveです
 - マニフェストを適用することでMySQLのサンプルDBである[world](https://dev.mysql.com/doc/index-other.html)がリストアされます
 - MHAでの監視対象です
 - ベースのイメージは[centos:7](https://hub.docker.com/_/centos)です

#### masterha001

 - MHAマネージャが動いています
 - ベースのイメージは[centos:7](https://hub.docker.com/_/centos)です

#### puppetserver

 - puppetserverが動いています
 - 各コンテナのセットアップのために使用します
 - ベースのイメージは[puppet/puppetserver:latest](https://hub.docker.com/r/puppet/puppetserver/)です

## MHAについて

ここでは本検証環境での手順のみを記載します。
MHAについて詳しく知りたい場合は、以下を参照してください。

ref：https://code.google.com/archive/p/mysql-master-ha/

### 構成の確認

各コンテナに対してsshで接続できるかの確認
```
$ docker exec -it masterha001 /bin/bash -c 'masterha_check_ssh --conf /etc/masterha/mha_app.cnf'
```

レプリケーションに問題がないかの確認
```
$ docker exec -it masterha001 /bin/bash -c 'masterha_check_repl --conf /etc/masterha/mha_app.cnf'
```

### switchover

以下の手順でswitchoverができます。

監視を停止する。
停止しないとswitchoverの動作を障害とご検知してfailoverが発生してしまいます。
```
$ docker exec -it masterha001 /bin/bash -c 'supervisorctl stop masterha_manager_mha_app'
```

停止した状態で以下のコマンドを実行することでswitchoverを実行できます。
```
$ docker exec -it masterha001 /bin/bash -c  '/usr/bin/masterha_master_switch --conf=/etc/masterha/mha_app.cnf --master_state=alive --orig_master_is_new_slave'
```

switchoverが終わったら監視を再開します。
```
$ docker exec -it masterha001 /bin/bash -c 'supervisorctl start masterha_manager_mha_app'
```

### failover

masterになっているノード（setup直後はdb001）で、dbのプロセスを落とすなり何かしらの障害を発生させればfailoverが実行されます。
