resource "aws_efs_file_system" "jenkins2_efs_master" {
  creation_token = "jenkins2_efs_${var.team_name}_${var.environment}"

  tags {
    Name        = "jenkins2-efs-${var.environment}-${var.team_name}"
    ManagedBy   = "terraform"
    Team        = "${var.team_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_efs_mount_target" "jenkins2_efs_master_mount" {
  file_system_id  = "${aws_efs_file_system.jenkins2_efs_master.id}"
  subnet_id       = "${element(module.jenkins2_vpc.public_subnets,0)}"
  security_groups = ["${module.jenkins2_sg_efs.this_security_group_id}"]
}

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
