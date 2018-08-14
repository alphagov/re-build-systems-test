module "dns" {
  # The next line needs to be a link to where the DNS module has been downloaded.
  source  = "./dns_module"
  version = "1.0.0"

  team_name       = "${var.team_name}"
  hostname_suffix = "${var.hostname_suffix}"
}

module "jenkins" {
  # The next line needs to be a link to where the Jenkins module has been downloaded.
  source  = "./jenkins_module"
  version = "1.0.0"

  # Environment configuration.
  allowed_ips = "${var.allowed_ips}"
  az          = "${var.aws_az}"
  environment = "${var.environment}"
  region      = "${var.aws_region}"
  team_name   = "${var.team_name}"

  # Git repo
  gitrepo        = "${var.gitrepo}"
  gitrepo_branch = "${var.gitrepo_branch}"

  # Github auth configuration
  github_admin_users   = ["${join(",", var.github_admin_users)}"]
  github_client_id     = "${var.github_client_id}"
  github_client_secret = "${var.github_client_secret}"
  github_organisations = ["${join(",", var.github_organisations)}"]

  # Public key
  ssh_public_key_file = "${var.ssh_public_key_file}"

  # DNS configuration
  hostname_suffix      = "${var.hostname_suffix}"
  route53_team_zone_id = "${module.dns.team_zone_id}"

  docker_version = "${var.docker_version}"

  # Ubuntu Version
  ubuntu_release = "${var.ubuntu_release}"

  # Server Configuration
  server_instance_type    = "${var.server_instance_type}"
  server_name             = "${var.server_name}"
  server_user_data        = "${var.server_user_data}"
  server_root_volume_size = "${var.server_root_volume_size}"

  # Worker Configuration
  worker_instance_type    = "${var.worker_instance_type}"
  worker_name             = "${var.worker_name}"
  worker_user_data        = "${var.worker_user_data}"
  worker_root_volume_size = "${var.worker_root_volume_size}"
}
