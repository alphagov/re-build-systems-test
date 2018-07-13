module "jenkins2_sg_efs" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.22.0"

  name        = "jenkins2_sg_efs_${var.team_name}_${var.environment}"
  description = "Jenkins2 Security Group Allowing EFS Access"
  vpc_id      = "${module.jenkins2_vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "Allow connection from the servers to EFS"
      cidr_blocks = "${var.public_subnet}"
    },
  ]
}
