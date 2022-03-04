# Instances:

# Infra Instance:
resource "aws_instance" "infra" {
  instance_type = "${var.aws_instance_type_infra}"
  ami           = "${var.aws_ami}"
  key_name      = "${var.aws_key_pair_name}"

  root_block_device {
    volume_size = "${var.infra_root_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Second disk for docker storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.infra_docker_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  vpc_security_group_ids = ["${aws_security_group.gecs-instance-sg.id}"]

  subnet_id = "${aws_subnet.gecs-subnet.id}"

  user_data = "${file("userdata.sh")}"

  tags = {
    Name    = "${var.tag_owner}_${var.name_prefix}_infra"
    owner   = "${var.tag_owner}"
    purpose = "${var.tag_purpose}"
    enddate = "${var.tag_enddate}"
  }
}

# CDP OneNodeCluster Instance:
resource "aws_instance" "cdp" {
  instance_type = "${var.aws_instance_type_cdp}"
  ami           = "${var.aws_ami}"
  key_name      = "${var.aws_key_pair_name}"

  root_block_device {
    volume_size = "${var.cdp_root_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Second disk for CDSW docker storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.cdp_cdsw_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  vpc_security_group_ids = ["${aws_security_group.gecs-instance-sg.id}"]

  subnet_id = "${aws_subnet.gecs-subnet.id}"

  user_data = "${file("userdata.sh")}"

  tags = {
    Name    = "${var.tag_owner}_${var.name_prefix}_cdp"
    owner   = "${var.tag_owner}"
    purpose = "${var.tag_purpose}"
    enddate = "${var.tag_enddate}"
  }
}

# ECS Cluster Instances:
resource "aws_instance" "ecs" {
  instance_type = "${var.aws_instance_type_ecs}"
  ami           = "${var.aws_ami}"
  key_name      = "${var.aws_key_pair_name}"

  root_block_device {
    volume_size = "${var.ecs_root_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Second disk for docker storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.ecs_docker_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Third disk for PV volume storage
  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = "${var.ecs_pv_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  #iam_instance_profile = "${aws_iam_instance_profile.node_instance_profile.id}"

  vpc_security_group_ids = ["${aws_security_group.gecs-instance-sg.id}"]

  subnet_id = "${aws_subnet.gecs-subnet.id}"

  user_data = "${file("userdata.sh")}"

  count = "${var.ecs_node_count}"

  tags = {
    Name    = "${var.tag_owner}_${var.name_prefix}_ecs${count.index + 1}"
    owner   = "${var.tag_owner}"
    purpose = "${var.tag_purpose}"
    enddate = "${var.tag_enddate}"
  }
}
