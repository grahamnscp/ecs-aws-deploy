# ecs-aws-deploy

This repo contains code to deploy a very basic minimal test CDP Private Cloud test cluster on AWS EC2 as IaaS
CDP is configured on one node based on e2ai existing infra option and configured with PVC CDP-Base pre-requisites
A new template was created that uses public archive.cloudera.com repo so will work on any AWS EC2 VPC.
Additional nodes are created for a bare minimum ECS compute cluster to be provisioned.

The deployment is separated into two halves, using terraform to deploy the infrastructure and then ansible to configure and deploy the software.

Route53 is included so hostnames for the chosen subdomain and added to the existing hosted zone in the se account, including a wildcard \*.apps entry pointing to ecs1 host.
The code includes a docker image config, build and push that is deployed on a separate host called "infra" to provide a local resolving DNS for the private IP addresses of the EC2 instances, this ensures that all internal traffic stays on the private subnet.
IPA is also provisioned on the infra host, this is only used for external LDAP and Kerberos is provided by an MIT KDC instance on the CDP host.
(IPA-KDC is currently supported for CDP-PVC)

All settings have been moved to a params.sh file which is used by some config scripts to generate the required files for terraform and ansible.


## TL;DR Sequence to deploy is

**cp params.sh.example params.sh**\
edit as required to change the dummy values:
```
NAME_PREFIX=myecs

TAG_OWNER="me"
TAG_PURPOSE="infra devtest"
TAG_ENDDATE="DDMMYYYY"

AWS_KEY_PAIR_NAME="myawskeypair"
MY_SSH_PRIVATE_KEY_FILE="~\/.ssh\/mylocalkeypair"

IP_CIDR_ME="XXX.XXX.XXX.XXX\/32"
IP_CIDR_ME_VPN="XXX.XXX.XXX.XXX\/32"
IP_CIDR_OTHER="XXX.XXX.XXX.XXX/32"

CENTOS_PASSWORD=centospasswordvalue

DOCKERHUB_USER=mydockerhubid

CLOUDERA_MANAGER_LICENSE_FILE="~\/licenses\/my_2021_2022_Licenseinfo\/my_2021_2022_cloudera_license.txt"
CDP_REMOTE_REPO_USR=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CDP_REMOTE_REPO_PWD=xxxxxxxxxxxx
```


```
./setup-terraform-vars.sh
cd tf
terraform init
terraform plan
terraform apply -auto-approve
cd ..

./generate-dns.sh

./generate-ansible-files.sh

cd ansible
time ansible-playbook -i hosts site.yml

open http://cdp.myecs.cloudera-field.net:7180

```

## Provision an ECS cluster

WIP: looking at posting a cluster template for ECS cluster creation, need to specify the appdomain and correct locations of the mounted volumes as well as ensure that the ECS router host is ecs1 for the wildcard to point to the right place.

Login to the CDP-Base CM UI and provision a cluster..\
internet deployment\
select ecs1 for docker registry and docker ecs server, ecs2-x for the workers\
docker volume: /var/lib/docker\
longhorn volumes: /ecs/\* (vs /ecs/ecs/\*)\
\
Takes a while to download and push the ecs docker images into the local registry, this is spawned out to run in parallel on the ecs hosts
When the ecs services are starting up for the first time the kubernetes cluster is already running so can check the status of the pods etc.
I added a script to parse the kubeconfig file copied back from the ecs1 host below, run the playbook to grab it first:


## Collect the kubeconfig locally
```
(in the ansible sub-directory)
ansible-playbook -i hosts site-fetch-kubecfg.yml
cd working-files
./generate-kubeconfig
```

note: the kubernetes controller will only respond if accessed using a SAN in it's configured certificate, so a local hosts entry needs to be added to your laptop along with the \*public\* ip of the ecs1 server. kubernetes.default.svc.cluster.local works.

