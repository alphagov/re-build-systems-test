resource "aws_efs_file_system" "jenkins2_master_fs" {
  # creation_token = "jenkins2-master-fs"

  tags {
    Name        = "Jenkins2-efs-${var.environment}-${var.team_name}"
    ManagedBy   = "terraform"
    Team        = "${var.team_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_efs_mount_target" "alpha" {
  file_system_id = "${aws_efs_file_system.jenkins2_master_fs.id}"
  subnet_id      = "${element(module.jenkins2_vpc.public_subnets,0)}"
}
