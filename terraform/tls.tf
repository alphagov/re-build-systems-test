locals {
  san_domains = [
#    "www.${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}",
    "asg.${var.environment}.${var.team_name}.${var.hostname_suffix}",
  ]
}

resource "aws_acm_certificate" "tls_certificate" {
  domain_name               = "${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}"
  validation_method         = "DNS"
  subject_alternative_names = "${local.san_domains}"
}

resource "aws_route53_record" "dns_validation" {
  count   = "${length(local.san_domains) + 1}"
  zone_id = "${data.terraform_remote_state.team_dns_and_eips.team_zone_id}"
  name    = "${lookup(aws_acm_certificate.tls_certificate.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.tls_certificate.domain_validation_options[count.index], "resource_record_type")}"
  records = ["${lookup(aws_acm_certificate.tls_certificate.domain_validation_options[count.index], "resource_record_value")}"]
  ttl     = 60
}
