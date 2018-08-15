module "dns" {
  source = "git::https://github.com/alphagov/terraform-aws-re-build-dns.git?ref=0.0.1"

  team_name       = "${var.team_name}"
  hostname_suffix = "${var.hostname_suffix}"
}
