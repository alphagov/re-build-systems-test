output "jenkins2_eips_id" {
  value = "${aws_eip.jenkins2_eips.*.id}"
}

output "jenkins2_eips_ip" {
  value = "${aws_eip.jenkins2_eips.*.public_ip}"
}

output "jenkins2_env_eip_ids" {
  value = "${zipmap(var.team_environments, aws_eip.jenkins2_eips.*.id)}"
}

output "jenkins2_env_eip_ips" {
  value = "${zipmap(var.team_environments, aws_eip.jenkins2_eips.*.public_ip)}"
}

output "team_domain_name" {
  value = "${var.team_name}.${var.top_level_domain_name}"
}

output "team_zone_id" {
  value = "${aws_route53_zone.primary_zone.zone_id}"
}

output "primary_zone_id" {
  value = "${aws_route53_zone.primary_zone.zone_id}"
}

output "team_zone_nameservers" {
  value = "${aws_route53_zone.primary_zone.name_servers}"
}
