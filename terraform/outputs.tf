output "image_id" {
  value = "${data.aws_ami.source.id}"
}

output "jenkins2_eip" {
  value = "${aws_eip.jenkins2_eip.public_ip}"
}

# Commented because this DNS name resolves to the original public IPv4 address of the EC2. We need the public DNS name that resolves to the eip.
# output "jenkins2_dns_name" {
#   description = "Jenkins2 DNS name - uri of the EC2 instance created"
#   value = ["${module.jenkins2_server.public_dns}"]
# }

output "jenkins2_security_group_id" {
  description = "jenkins2 default security group id"
  value       = "${module.jenkins2_security_group.this_security_group_id}"
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
