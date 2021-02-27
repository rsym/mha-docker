#!/bin/sh

ROOT_PASSWORD=${1:-'root-p@ssw0rd'}
REPL_PASSWORD=${2:-'repl-p@ssw0rd'}
MHA_PASSWORD=${3:-'mha-p@ssw0rd'}

KEY_NAME='id_mha'
ssh-keygen -t rsa -m pem -f ${KEY_NAME} -P '' -C '' > /dev/null
SSH_PUBLIC_KEY=$(cat "${KEY_NAME}.pub" | sed -e 's/^ssh-rsa //')

LABEL_SSH_PUBLIC_KEY='root::ssh_public_key'
LABEL_SSH_PRIVATE_KEY='root::ssh_private_key'
LABEL_ROOT_PASSWORD='mysql_user::root::password'
LABEL_REPL_PASSWORD='mysql_user::repl::password'
LABEL_MHA_PASSWORD='mysql_user::mha::password'

ENCRYPT='bundle exec eyaml encrypt --output=string'

cat << EOS
---
$(${ENCRYPT} --label ${LABEL_SSH_PUBLIC_KEY} --string ${SSH_PUBLIC_KEY})
$(${ENCRYPT} --label ${LABEL_SSH_PRIVATE_KEY} --file ${KEY_NAME})

$(${ENCRYPT} --label ${LABEL_ROOT_PASSWORD} --string ${ROOT_PASSWORD})
$(${ENCRYPT} --label ${LABEL_REPL_PASSWORD} --string ${REPL_PASSWORD})
$(${ENCRYPT} --label ${LABEL_MHA_PASSWORD}  --string ${MHA_PASSWORD})


paste aboves to ./hieradata/\${::environment}_secret.yaml

mysql_user::root::password is $ROOT_PASSWORD
mysql_user::repl::password is $REPL_PASSWORD
mysql_user::mha::password is $MHA_PASSWORD
EOS

rm ${KEY_NAME} "${KEY_NAME}.pub"
