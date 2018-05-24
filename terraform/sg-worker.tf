module "jenkins2_sg_worker" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.22.0"

  name        = "jenkins2_sg_worker_${var.product}_${var.environment}"
  description = "Jenkins2 Security Group Allowing HTTP and SSH"
  vpc_id      = "${module.jenkins2_vpc.vpc_id}"

  egress_rules = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 2375
      to_port     = 2375
      protocol    = "tcp"
      description = "Server connecting to Docker API"
      cidr_blocks = "${var.public_subnet}"
    },
  ]
}
