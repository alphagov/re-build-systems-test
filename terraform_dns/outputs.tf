output "primary_zone_id" {
  value = "${aws_route53_zone.primary_zone.zone_id}"
}

output "primary_zone_nameservers" {
  value = "${aws_route53_zone.primary_zone.name_servers}"
}
