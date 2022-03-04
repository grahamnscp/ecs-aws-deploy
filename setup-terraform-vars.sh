#!/bin/bash

source ./params.sh

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

# Subsitute terraform variables to generate variables.tf
echo ">>> Generating Terraform ./tf/variables.tf file from ./templates/variables.tf.template.."
cp ./templates/variables.tf.template ./tf/variables.tf

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##NAME_PREFIX##/$NAME_PREFIX/" ./tf/variables.tf
sed -i $SEDBAK "s/##ROUTE53_DOMAINNAME##/$ROUTE53_DOMAINNAME/" ./tf/variables.tf
sed -i $SEDBAK "s/##ROUTE53_ZONE_ID##/$ROUTE53_ZONE_ID/" ./tf/variables.tf
sed -i $SEDBAK "s/##TAG_OWNER##/$TAG_OWNER/" ./tf/variables.tf
sed -i $SEDBAK "s/##TAG_PURPOSE##/$TAG_PURPOSE/" ./tf/variables.tf
sed -i $SEDBAK "s/##TAG_ENDDATE##/$TAG_ENDDATE/" ./tf/variables.tf
sed -i $SEDBAK "s/##AWS_REGION##/$AWS_REGION/" ./tf/variables.tf
sed -i $SEDBAK "s/##AWS_KEY_PAIR_NAME##/$AWS_KEY_PAIR_NAME/" ./tf/variables.tf
sed -i $SEDBAK "s/##IP_CIDR_ME##/$IP_CIDR_ME/" ./tf/variables.tf
sed -i $SEDBAK "s/##IP_CIDR_ME_VPN##/$IP_CIDR_ME_VPN/" ./tf/variables.tf
sed -i $SEDBAK "s/##IP_CIDR_OTHER##/$IP_CIDR_ME_VPN/" ./tf/variables.tf
sed -i $SEDBAK "s/##AWS_AMI##/$AWS_AMI/" ./tf/variables.tf
sed -i $SEDBAK "s/##AWS_INSTANCE_TYPE_INFRA##/$AWS_INSTANCE_TYPE_INFRA/" ./tf/variables.tf
sed -i $SEDBAK "s/##AWS_INSTANCE_TYPE_CDP##/$AWS_INSTANCE_TYPE_CDP/" ./tf/variables.tf
sed -i $SEDBAK "s/##AWS_INSTANCE_TYPE_ECS##/$AWS_INSTANCE_TYPE_ECS/" ./tf/variables.tf
sed -i $SEDBAK "s/##INFRA_ROOT_VOLUME_SIZE##/$INFRA_ROOT_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##INFRA_DOCKER_VOLUME_SIZE##/$INFRA_DOCKER_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##CDP_ROOT_VOLUME_SIZE##/$CDP_ROOT_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##CDP_CDSW_VOLUME_SIZE##/$CDP_CDSW_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##ECS_ROOT_VOLUME_SIZE##/$ECS_ROOT_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##ECS_DOCKER_VOLUME_SIZE##/$ECS_DOCKER_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##ECS_PV_VOLUME_SIZE##/$ECS_PV_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##ECS_NODE_COUNT##/$ECS_NODE_COUNT/" ./tf/variables.tf
sed -i $SEDBAK "s/##VPCCIDRBLOCK##/$VPCCIDRBLOCK/" ./tf/variables.tf
sed -i $SEDBAK "s/##SUBNETCIDRBLOCK##/$SUBNETCIDRBLOCK/" ./tf/variables.tf

rm ./tf/variables.tf.bak

exit 0
