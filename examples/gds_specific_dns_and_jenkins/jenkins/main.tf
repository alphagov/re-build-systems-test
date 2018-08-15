module "jenkins" {
  source = "git::https://github.com/alphagov/terraform-aws-re-build-jenkins.git?ref=0.0.1"

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
  route53_team_zone_id = "${data.terraform_remote_state.team_dns.team_zone_id}"

  docker_version = "${var.docker_version}"

  # Server Configuration
  server_instance_type    = "${var.server_instance_type}"
  server_name             = "${var.server_name}"
  server_root_volume_size = "${var.server_root_volume_size}"

  # Worker Configuration
  worker_instance_type    = "${var.worker_instance_type}"
  worker_name             = "${var.worker_name}"
  worker_root_volume_size = "${var.worker_root_volume_size}"
}
