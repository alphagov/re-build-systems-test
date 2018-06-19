resource "aws_key_pair" "deployer-ssh-key" {
  key_name   = "jenkins2_key_${var.team_name}_${var.environment}"
  public_key = "${file("${ssh_public_key_file}")}"
}
