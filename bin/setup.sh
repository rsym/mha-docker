#!/bin/bash

# docker-compose
docker-compose up -d --build --force-recreate

echo "starting puppetserver\c"
while [ $(docker-compose ps | grep puppetserver | awk '{print $6}') != '(healthy)' ]
do
  echo ".\c"
  sleep 1
  if [ $(docker-compose ps | grep puppetserver | awk '{print $5}') == 'Exit' ]; then
    echo "\nstarting puppetserver is failed."
    exit 1
  fi
done
echo

# puppet apply
docker exec -it puppetserver /bin/bash -c "/opt/puppetlabs/bin/puppet generate types --environment development"
sh ./bin/provision.sh db001
sh ./bin/provision.sh db002
sh ./bin/provision.sh db003
sh ./bin/provision.sh masterha001
