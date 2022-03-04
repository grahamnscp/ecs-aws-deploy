#!/bin/bash

#clean generated cdp files
test -e ansible/hosts && rm ansible/hosts
test -e ansible/working-files/setup.sh && rm ansible/working-files/setup.sh
test -e ansible/working-files/common.sh && rm ansible/working-files/common.sh
test -e ansible/working-files/create-test-users.sh && rm ansible/working-files/create-test-users.sh

#clean generated ecs files
test -e ansible/working-files/myRSAkey && rm -rf ansible/working-files/myRSAkey*
test -e ansible/working-files/cdp-ca.tar && rm ansible/working-files/cdp-ca.tar
test -e ansible/working-files/krb5.conf && rm ansible/working-files/krb5.conf
test -e ansible/working-files/kubecfg/admin.yaml && rm -rf ansible/working-files/kubecfg/*

#clean generated bind-docker image file
test -e ansible/working-files/resolv.conf && rm ansible/working-files/resolv.conf
test -e bind-docker/configs/named.conf.cdp && rm bind-docker/configs/named.conf.cdp
rm bind-docker/varbind/cdp/*

#clean generated terraform variables file - needed to destroy first!
#test -e tf/variables.tf && rm tf/variables.tf
