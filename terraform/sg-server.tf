module "jenkins2_sg_server_internet_facing" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.22.0"

  name        = "jenkins2_sg_server_internet_facing_${var.product}_${var.environment}"
  description = "Jenkins2 Security Group Allowing HTTP and SSH from Internet"
  vpc_id      = "${module.jenkins2_vpc.vpc_id}"

  ingress_cidr_blocks = ["${var.allowed_ips}"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "jenkins2_sg_server_private_facing" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.22.0"

  name        = "jenkins2_sg_server_private_facing_${var.product}_${var.environment}"
  description = "Jenkins2 Security Group Allowing Server to Worker Communication"
  vpc_id      = "${module.jenkins2_vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 50000
      to_port     = 50000
      protocol    = "tcp"
      description = "Docker hosts talking back to server - JNLP"
      cidr_blocks = "${var.public_subnet}"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Docker hosts talking back to server - HTTP"
      cidr_blocks = "${var.public_subnet}"
    },
  ]
}
