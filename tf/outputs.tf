# Output Values:

output "region" {
  value = "${var.aws_region}"
}

# Domain
output "route53_subdomain" {
  value = "${var.name_prefix}"
}
output "route53_domain" {
  value = "${var.route53_domainname}"
}

# Infra Instance
output "infra-instance-public-name" {
  value = "${aws_instance.infra.public_dns}"
}
output "infra-instance-public-ip" {
  value = "${aws_instance.infra.public_ip}"
}
output "infra-instance-private-name" {
  value = "${aws_instance.infra.private_dns}"
}
output "infra-instance-private-ip" {
  value = "${aws_instance.infra.private_ip}"
}

# CDP Instance
output "cdp-instance-public-name" {
  value = "${aws_instance.cdp.public_dns}"
}
output "cdp-instance-public-ip" {
  value = "${aws_instance.cdp.public_ip}"
}
output "cdp-instance-private-name" {
  value = "${aws_instance.cdp.private_dns}"
}
output "cdp-instance-private-ip" {
  value = "${aws_instance.cdp.private_ip}"
}

# ECS Instances
output "ecs-node-public-names" {
  value = ["${aws_instance.ecs.*.public_dns}"]
}
output "ecs-node-public-ips" {
  value = ["${aws_instance.ecs.*.public_ip}"]
}
output "ecs-node-private-names" {
  value = ["${aws_instance.ecs.*.private_dns}"]
}
output "ecs-node-private-ips" {
  value = ["${aws_instance.ecs.*.private_ip}"]
}

# DNS names
output "route53-cdp" {
  value = ["${aws_route53_record.cdp.name}"]
}
output "route53-infra" {
  value = ["${aws_route53_record.infra.name}"]
}
output "route53-ecs-nodes" {
  value = ["${aws_route53_record.ecs.*.name}"]
}
output "route53-apps-wildcard" {
  value = ["${aws_route53_record.wildcard.name}"]
}

