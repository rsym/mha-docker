#!/bin/bash

CONTAINER=$1
PUPPET_APPLY="puppet agent --environment=development --test --server puppetserver"

if [ "${#CONTAINER}" -eq 0 ]; then
  docker exec -it db001 /bin/bash -c "${PUPPET_APPLY}"
  docker exec -it db002 /bin/bash -c "${PUPPET_APPLY}"
  docker exec -it db003 /bin/bash -c "${PUPPET_APPLY}"
  docker exec -it masterha001 /bin/bash -c "${PUPPET_APPLY}"
else
  docker exec -it "${CONTAINER}" /bin/bash -c "${PUPPET_APPLY}"
fi
