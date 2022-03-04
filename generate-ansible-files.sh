#!/bin/bash

# load in parameters
source ./params.sh


CWD=`pwd`
TMP_FILE=/tmp/generate-hosts.tmp.$$

# sed -i has extra param in OSX
SEDBAK=""

UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac
                SEDBAK=".bak"
                ;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${UNAME_OUT}"
esac

# ---------------------------------------
# Collect output variables from terraform
# ---------------------------------------
echo ">>> Collecting variables from terraform output.."

cd tf
terraform output > $TMP_FILE
cd $CWD

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g' |sed 's/\"//g' |sed 's/,*$//g'`
  #echo ENTRY: $var_name = $var_value

  case $var_name in
    "route53_domain")
      BASEDOMAIN=$var_value
      ;;

    "route53_subdomain")
      SUBDOMAIN=$var_value
      ;;

    "cdp-instance-public-ip")
      CDP_IP=$var_value
      ;;

    "cdp-instance-private-ip")
      CDP_PRIVATE_IP=$var_value
      ;;

    "infra-instance-public-ip")
      INFRA_IP=$var_value
      ;;

    "infra-instance-private-ip")
      INFRA_PRIVATE_IP=$var_value
      ;;

    "ecs-node-public-ips")
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        ECS_PUBLIC_IPS[$COUNT]=$entry
      done
      NUM_ECS_IPS=$COUNT
      ;;

    "route53-ecs-nodes")
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        ECS_PUBLIC_NAMES[$COUNT]=$entry
      done
      NUM_ECS_NAMES=$COUNT
      ;;
  esac
done


# Variables
DOMAIN=${SUBDOMAIN}.${BASEDOMAIN}

# ---------------------------------
# Generate hosts file from template
# ---------------------------------
echo ">>> Generating ansible/hosts file from templates/hosts.template.."

cp templates/hosts.template ansible/hosts
sed -i $SEDBAK "s/##BASEDOMAIN##/$BASEDOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##SUBDOMAIN##/$SUBDOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##MY_SSH_PRIVATE_KEY_FILE##/$MY_SSH_PRIVATE_KEY_FILE/" ansible/hosts
sed -i $SEDBAK "s/##CENTOS_PASSWORD##/$CENTOS_PASSWORD/" ansible/hosts
sed -i $SEDBAK "s/##NTP_PRIVATE_SUBNET##/$NTP_PRIVATE_SUBNET/" ansible/hosts
sed -i $SEDBAK "s/##DOCKER_STORAGE_DEVICE##/\"$DOCKER_STORAGE_DEVICE\"/" ansible/hosts
sed -i $SEDBAK "s/##CDP_CDSW_STORAGE_DEVICE##/\"$CDP_CDSW_STORAGE_DEVICE\"/" ansible/hosts
sed -i $SEDBAK "s/##DOCKERHUB_USER##/$DOCKERHUB_USER/" ansible/hosts
sed -i $SEDBAK "s/##BIND_DOCKER_TAG##/$BIND_DOCKER_TAG/" ansible/hosts
sed -i $SEDBAK "s/##IPA_PASSWORD##/$IPA_PASSWORD/" ansible/hosts
sed -i $SEDBAK "s/##IPA_REALM##/$IPA_REALM/" ansible/hosts
sed -i $SEDBAK "s/##CLOUDERA_MANAGER_VERSION##/$CLOUDERA_MANAGER_VERSION/" ansible/hosts
sed -i $SEDBAK "s/##CDP_CLUSTER_TEMPLATE##/$CDP_CLUSTER_TEMPLATE/" ansible/hosts
sed -i $SEDBAK "s/##SPARK3_PARCEL_VERSION##/$SPARK3_PARCEL_VERSION/" ansible/hosts
sed -i $SEDBAK "s/##CLOUDERA_MANAGER_LICENSE_FILE##/\"$CLOUDERA_MANAGER_LICENSE_FILE\"/" ansible/hosts
sed -i $SEDBAK "s/##CDP_REMOTE_REPO_USR##/\"$CDP_REMOTE_REPO_USR\"/" ansible/hosts
sed -i $SEDBAK "s/##CDP_REMOTE_REPO_PWD##/\"$CDP_REMOTE_REPO_PWD\"/" ansible/hosts
sed -i $SEDBAK "s/##CDP_CLUSTER_NAME##/$CDP_CLUSTER_NAME/" ansible/hosts
sed -i $SEDBAK "s/##CLOUDERA_MANAGER_API_USER##/$CLOUDERA_MANAGER_API_USER/" ansible/hosts
sed -i $SEDBAK "s/##CLOUDERA_MANAGER_API_PASSWORD##/$CLOUDERA_MANAGER_API_PASSWORD/" ansible/hosts
# External Auth
sed -i $SEDBAK "s/##LDAP_URL##/\"$LDAP_URL\"/" ansible/hosts
sed -i $SEDBAK "s/##LDAP_BIND_DN##/\"$LDAP_BIND_DN\"/" ansible/hosts
sed -i $SEDBAK "s/##LDAP_BIND_PW##/$LDAP_BIND_PW/" ansible/hosts
sed -i $SEDBAK "s/##LDAP_USER_SEARCH_BASE##/\"$LDAP_USER_SEARCH_BASE\"/" ansible/hosts
sed -i $SEDBAK "s/##LDAP_USER_SEARCH_FILTER##/\"$LDAP_USER_SEARCH_FILTER\"/" ansible/hosts
sed -i $SEDBAK "s/##LDAP_GROUP_SEARCH_BASE##/\"$LDAP_GROUP_SEARCH_BASE\"/" ansible/hosts
sed -i $SEDBAK "s/##LDAP_GROUP_SEARCH_FILTER##/\"$LDAP_GROUP_SEARCH_FILTER\"/" ansible/hosts
sed -i $SEDBAK "s/##HUE_USER_FILTER##/\"$HUE_USER_FILTER\"/" ansible/hosts
sed -i $SEDBAK "s/##HUE_USER_NAME_ATTR##/\"$HUE_USER_NAME_ATTR\"/" ansible/hosts
sed -i $SEDBAK "s/##HUE_GROUP_FILTER##/\"$HUE_GROUP_FILTER\"/" ansible/hosts
sed -i $SEDBAK "s/##HUE_GROUP_NAME_ATTR##/\"$HUE_GROUP_NAME_ATTR\"/" ansible/hosts
sed -i $SEDBAK "s/##HUE_GROUP_MEMBER_ATTR##/\"$HUE_GROUP_MEMBER_ATTR\"/" ansible/hosts
sed -i $SEDBAK "s/##HUE_TEST_LDAP_USER##/\"$HUE_TEST_LDAP_USER\"/" ansible/hosts
sed -i $SEDBAK "s/##HUE_TEST_LDAP_GROUP##/\"$HUE_TEST_LDAP_GROUP\"/" ansible/hosts

# ECS playbook variables:
sed -i $SEDBAK "s/##ECS_DOCKER_STORAGE_DEVICE##/\"$ECS_DOCKER_STORAGE_DEVICE\"/" ansible/hosts
sed -i $SEDBAK "s/##ECS_STORAGE_DEVICE##/\"$ECS_STORAGE_DEVICE\"/" ansible/hosts
sed -i $SEDBAK "s/##SCM_CERT_PASSWORD##/\"$SCM_CERT_PASSWORD\"/" ansible/hosts

# Host entries
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##INFRA_IP##/$INFRA_IP/" ansible/hosts
sed -i $SEDBAK "s/##CDP_IP##/$CDP_IP/" ansible/hosts
#
# Add variable ecs node entries at bottom of file:
for (( COUNT=1; COUNT<=$NUM_ECS_IPS; COUNT++ ))
do
  echo "ecs${COUNT}    ansible_host=${ECS_PUBLIC_IPS[$COUNT]}   fqdn=${ECS_PUBLIC_NAMES[$COUNT]}" >> ansible/hosts
done
echo "" >> ansible/hosts

# ------------------------------------------
# Generate ansible edge2ai resources scripts
# ------------------------------------------
echo ">>> Generating ansible/working-files/setup.sh file from templates/setup.sh.template.."
cp templates/setup.sh.template ansible/working-files/setup.sh
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/" ansible/working-files/setup.sh

echo ">>> Generating ansible/working-files/common.sh file from templates/common.sh.template.."
cp templates/common.sh.template ansible/working-files/common.sh
sed -i $SEDBAK "s/##KRB_REALM##/$KRB_REALM/" ansible/working-files/common.sh
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/" ansible/working-files/common.sh
sed -i $SEDBAK "s/##ADMIN_PASSWORD##/$ADMIN_PASSWORD/" ansible/working-files/common.sh

echo ">>> Generating ansible/working-files/create_cluster.py file from templates/create_cluster.py.template.."
cp templates/create_cluster.py.template ansible/working-files/create_cluster.py
sed -i $SEDBAK "s/##REALM##/$KRB_REALM/" ansible/working-files/create_cluster.py

echo ">>> Generating ansible/working-files/create-test-users.sh file from templates/create-test-users.sh.template.."
cp templates/create-test-users.sh.template ansible/working-files/create-test-users.sh
sed -i $SEDBAK "s/##KRB_REALM##/$KRB_REALM/" ansible/working-files/create-test-users.sh


# --------
# All done
# --------
echo ">>> done."
/bin/rm $TMP_FILE
rm ansible/hosts.bak
rm ansible/working-files/*.bak

exit 0

