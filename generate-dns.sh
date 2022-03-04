#!/bin/bash

# Read in the parameters
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
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g' |sed 's/\"//g'`
  #echo ENTRY: $var_name = $var_value

  case $var_name in
    "route53_domain")
      BASEDOMAIN=$var_value
      ;;

    "route53_subdomain")
      SUBDOMAIN=$var_value
      ;;

    "infra-instance-private-ip")
      INFRA_PRIVATE_IP=$var_value
      ;;

    "cdp-instance-private-ip")
      CDP_PRIVATE_IP=$var_value
      ;;

    "ecs-node-private-ips")
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        ECS_PRIVATE_IPS[$COUNT]=$entry
      done
      NUM_ECS_IPS=$COUNT
      ;;
  esac
done

# --------------------------------------------------
# Configure DNS entries for Docker bind-docker image
# --------------------------------------------------
echo ">>> Generating bind-docker/varbind/cdp entries for bind-docker image.."

DOMAIN=${SUBDOMAIN}.${BASEDOMAIN}
PRIVATE_SUBNET_NET=`echo ${INFRA_PRIVATE_IP} |awk -F "." '{print $1"."$2"."$3}'`
PRIVATE_SUBNET_REV=`echo ${INFRA_PRIVATE_IP} |awk -F "." '{print $3"."$2"."$1}'`
INFRA_IP_NUM=`echo $INFRA_PRIVATE_IP |awk -F "." '{print $4}'`
CDP_IP_NUM=`echo $CDP_PRIVATE_IP |awk -F "." '{print $4}'`
#
PRIVATE_VPC_NET=`echo ${VPCCIDRBLOCK} |awk -F "." '{print $1"."$2"."$3}'`
AWS_META_DNS=${PRIVATE_VPC_NET}.2
#
ZONE_CONFIG_DIR=bind-docker/varbind/cdp
mkdir -p ${ZONE_CONFIG_DIR}
DNS_F=${ZONE_CONFIG_DIR}/${DOMAIN}.db
DNS_R=${ZONE_CONFIG_DIR}/db.${PRIVATE_SUBNET_REV}.in-addr.arpa

# subsitute token values in zone config files
cp templates/named.conf.cdp.template bind-docker/configs/named.conf.cdp
sed -i $SEDBAK "s/##DOMAIN##/${DOMAIN}/g" bind-docker/configs/named.conf.cdp
sed -i $SEDBAK "s/##SUBNET_REV##/${PRIVATE_SUBNET_REV}/g" bind-docker/configs/named.conf.cdp

cp templates/subdomain.domain.db.template ${DNS_F}
cp templates/db.reversesubnet.in-addr.arpa.template ${DNS_R}
# forward lookup:
ECSX_IP_NUM=` echo ${ECS_PRIVATE_IPS[1]} |awk -F "." '{print $4}'`
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/g" ${DNS_F}
sed -i $SEDBAK "s/##INFRA_IP_NUM##/${PRIVATE_SUBNET_NET}.${INFRA_IP_NUM}/g" ${DNS_F}
sed -i $SEDBAK "s/##CDP_IP_NUM##/${PRIVATE_SUBNET_NET}.${CDP_IP_NUM}/g" ${DNS_F}
sed -i $SEDBAK "s/##ECSX_IP_NUM##/${PRIVATE_SUBNET_NET}.${ECSX_IP_NUM}/g" ${DNS_F}
# reverse lookup:
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/g" ${DNS_R}
sed -i $SEDBAK "s/##INFRA_IP_NUM##/$INFRA_IP_NUM/g" ${DNS_R}
sed -i $SEDBAK "s/##CDP_IP_NUM##/$CDP_IP_NUM/g" ${DNS_R}
sed -i $SEDBAK "s/##SUBNET_REV##/$PRIVATE_SUBNET_REV/g" ${DNS_R}
# add ecs node entries to both lookups
for (( COUNT=1;COUNT<=$NUM_ECS_IPS; COUNT++ ))
do
  ECS_IP_NUM[$COUNT]=`echo ${ECS_PRIVATE_IPS[$COUNT]} |awk -F "." '{print $4}'`
  echo "ecs${COUNT}              IN      A     ${PRIVATE_SUBNET_NET}.${ECS_IP_NUM[$COUNT]}" >> ${DNS_F}
  echo "${ECS_IP_NUM[$COUNT]}      IN     PTR     ecs${COUNT}.$DOMAIN." >> ${DNS_R}
done


# -----------------------------------------------
# Generate ansible/working-files/resolv.conf file
# -----------------------------------------------
echo ">>> Generating ansible/working-files/resolv.conf from templates/resolv.conf.template.."

cp templates/resolv.conf.template ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##INFRA_PRIVATE_IP##/$INFRA_PRIVATE_IP/" ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##AWS_META_DNS##/$AWS_META_DNS/" ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/" ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##AWS_REGION##/$AWS_REGION/" ansible/working-files/resolv.conf


# ---------------------------------------------------
# Build instance of bind-docker and push to dockerhub
# ---------------------------------------------------
echo ">>> Generating new instance of $DOCKERHUB_USER/bind-docker:$BIND_DOCKER_TAG.."

# tidy up before generating image and pushing
rm bind-docker/configs/*.bak
rm ${ZONE_CONFIG_DIR}/*.bak

cd bind-docker
docker build -t bind-docker:$BIND_DOCKER_TAG .
docker tag bind-docker:$BIND_DOCKER_TAG $DOCKERHUB_USER/bind-docker:$BIND_DOCKER_TAG
docker push $DOCKERHUB_USER/bind-docker:$BIND_DOCKER_TAG
cd $CWD


# --------
# All done
# --------
echo ">>> done."
/bin/rm $TMP_FILE
rm ansible/working-files/resolv.conf.bak

exit 0
