module "dns" {
  # The next line needs to be a link to where the DNS module has been downloaded.
  source  = "./dns_module"
  version = "1.0.0"

  team_name       = "${var.team_name}"
  hostname_suffix = "${var.hostname_suffix}"
}
