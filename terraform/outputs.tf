output "dns_state_bucket" {
  value = "tfstate-dns-${var.team_name}.${var.hostname_suffix}"
}

output "dns_state_file" {
  value = "${var.team_name}.${var.hostname_suffix}.tfstate"
}

output "environment" {
  value = "${var.environment}"
}

output "image_id" {
  value = "${data.aws_ami.source.id}"
}

output "jenkins2_env_eip_ids" {
  value = "${data.terraform_remote_state.team_dns_and_eips.jenkins2_env_eip_ids}"
}

output "jenkins2_env_eip" {
  value = "${lookup(data.terraform_remote_state.team_dns_and_eips.jenkins2_env_eip_ips, var.environment)}"
}

output "jenkins2_env_eip_ips" {
  value = "${data.terraform_remote_state.team_dns_and_eips.jenkins2_env_eip_ips}"
}

output "jenkins2_url" {
  value = "https://${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}"
}

output "jenkins2_vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.jenkins2_vpc.vpc_id}"
}

output "jenksin2_worker_public_ip" {
  description = "jenkins2 worker public ip"
  value       = ["${module.jenkins2_worker.public_ip}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.jenkins2_vpc.public_subnets}"]
}

output "team_domain_name" {
  value = "${data.terraform_remote_state.team_dns_and_eips.team_domain_name}"
}

output "team_zone_id" {
  value = "${data.terraform_remote_state.team_dns_and_eips.team_zone_id}"
}
