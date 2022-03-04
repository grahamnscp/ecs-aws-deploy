# Route53 for instances

resource "aws_route53_record" "infra" {
  zone_id = "${var.route53_zone_id}"
  name = "infra.${var.name_prefix}.${var.route53_domainname}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.infra.public_ip}"]
}

resource "aws_route53_record" "cdp" {
  zone_id = "${var.route53_zone_id}"
  name = "cdp.${var.name_prefix}.${var.route53_domainname}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.cdp.public_ip}"]
}

resource "aws_route53_record" "ecs" {
  zone_id = "${var.route53_zone_id}"
  count = "${var.ecs_node_count}"
  name = "ecs${count.index + 1}.${var.name_prefix}.${var.route53_domainname}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.ecs.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "wildcard" {
  zone_id = "${var.route53_zone_id}"
  name = "*.apps.${var.name_prefix}.${var.route53_domainname}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.ecs.*.public_ip, 0)}"]
}

