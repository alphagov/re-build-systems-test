output "image_id" {
  value = "${data.aws_ami.source.id}"
}

# Commented because this DNS name resolves to the original public IPv4 address of the EC2. We need the public DNS name that resolves to the eip.
# output "jenkins2_dns_name" {
#   description = "Jenkins2 DNS name - uri of the EC2 instance created"
#   value = ["${module.jenkins2_server.public_dns}"]
# }

output "jenkins2_sg_server_internet_facing_id" {
  description = "jenkins2 server internet security group id"
  value       = "${module.jenkins2_sg_server_internet_facing.this_security_group_id}"
}

output "jenkins2_sg_server_private_facing_id" {
  description = "jenkins2 server private security group id"
  value       = "${module.jenkins2_sg_server_private_facing.this_security_group_id}"
}

output "jenkins2_sg_worker_id" {
  description = "jenkins2 worker security group id"
  value       = "${module.jenkins2_sg_worker.this_security_group_id}"
}

output "jenksin2_server_private_ip" {
  description = "jenkins2 server private ip"
  value       = ["${module.jenkins2_server.private_ip}"]
}

output "jenksin2_server_public_ip" {
  description = "jenkins2 server public ip"
  value       = ["${module.jenkins2_server.public_ip}"]
}

output "jenkins2_vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.jenkins2_vpc.vpc_id}"
}

output "jenksin2_worker_private_ip" {
  description = "jenkins2 worker private ip"
  value       = ["${module.jenkins2_worker.private_ip}"]
}

output "jenksin2_worker_public_ip" {
  description = "jenkins2 worker public ip"
  value       = ["${module.jenkins2_worker.public_ip}"]
}

output "private_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.jenkins2_vpc.private_subnets}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.jenkins2_vpc.public_subnets}"]
}

output "jenkins2_env_eip_ids" {
  value = "${data.terraform_remote_state.customer_network.jenkins2_env_eip_ids}"
}

output "jenkins2_env_eip_ips" {
  value = "${data.terraform_remote_state.customer_network.jenkins2_env_eip_ips}"
}

output "jenkins2_env_eip" {
  value = "${lookup(data.terraform_remote_state.customer_network.jenkins2_env_eip_ips, var.environment)}"
}

output "team_domain_name" {
  value = "${data.terraform_remote_state.customer_network.team_domain_name}"
}

output "team_zone_id" {
  value = "${data.terraform_remote_state.customer_network.team_zone_id}"
}

output "dns_state_bucket" {
  value = "tfstate-dns-${var.team_name}.${var.hostname_suffix}"
}

output "dns_state_file" {
  value = "${var.team_name}.${var.hostname_suffix}.tfstate"
}
