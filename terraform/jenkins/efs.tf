resource "aws_efs_file_system" "jenkins2_efs_server" {
  creation_token = "efs-${var.server_name}.${var.environment}.${var.team_name}"

  tags {
    Name        = "efs-${var.server_name}.${var.environment}.${var.team_name}"
    ManagedBy   = "terraform"
    Team        = "${var.team_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_efs_mount_target" "jenkins2_efs_server_mount" {
  file_system_id  = "${aws_efs_file_system.jenkins2_efs_server.id}"
  subnet_id       = "${element(module.jenkins2_vpc.public_subnets,0)}"
  security_groups = ["${module.jenkins2_sg_efs.this_security_group_id}"]
}
