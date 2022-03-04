# vpc.tf

# VPC
resource "aws_vpc" "gecs-vpc" {
  cidr_block           = "${var.vpcCIDRblock}"
  instance_tenancy     = "${var.instanceTenancy}"
  enable_dns_support   = "${var.dnsSupport}"
  enable_dns_hostnames = "${var.dnsHostNames}"

  tags = {
    Name = "${var.name_prefix}_vpc"
    owner = "${var.tag_owner}"
    enddate = "${var.tag_enddate}"
  }
}

# Subnet
resource "aws_subnet" "gecs-subnet" {
  vpc_id                  = "${aws_vpc.gecs-vpc.id}"
  cidr_block              = "${var.subnetCIDRblock}"
  map_public_ip_on_launch = "${var.mapPublicIP}"

  tags = {
    Name = "${var.name_prefix}_subnet"
    owner = "${var.tag_owner}"
    enddate = "${var.tag_enddate}"
  }
}

# Gateway
resource "aws_internet_gateway" "gecs-gateway" {
  vpc_id = "${aws_vpc.gecs-vpc.id}"

  tags = {
    Name = "${var.name_prefix}_gateway"
    owner = "${var.tag_owner}"
    enddate = "${var.tag_enddate}"
  }
}

# Route
resource "aws_route_table" "gecs-route" {
  vpc_id = "${aws_vpc.gecs-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gecs-gateway.id}"
  }

  tags = {
    Name = "${var.name_prefix}_route"
    owner = "${var.tag_owner}"
    enddate = "${var.tag_enddate}"
  }
}

# Associate Route to Subnet
resource "aws_route_table_association" "gecs-subnet-route" {
  subnet_id      = "${aws_subnet.gecs-subnet.id}"
  route_table_id = "${aws_route_table.gecs-route.id}"
}
