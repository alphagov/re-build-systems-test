output "team_domain_name" {
  value = "${var.team_name}.${var.top_level_domain_name}"
}

output "team_zone_id" {
  value = "${aws_route53_zone.primary_zone.zone_id}"
}

output "team_zone_nameservers" {
  value = "${aws_route53_zone.primary_zone.name_servers}"
}
