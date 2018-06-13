resource "aws_route53_zone" "private_facing" {
  name   = "${var.environment}.internal"
  vpc_id = "${module.jenkins2_vpc.vpc_id}"

  tags {
    Environment = "${var.environment}"
    ManagedBy   = "terraform"
    Name        = "jenkins2_r53_private_${var.team_name}_${var.environment}"
    Team        = "${var.team_name}"
  }
}

resource "aws_route53_record" "jenkins2_eip_public" {
  zone_id = "${data.terraform_remote_state.customer_network.team_zone_id}"
  name    = "${var.server_name}.${var.environment}"
  type    = "A"
  ttl     = "60"

  #records = ["${aws_eip.jenkins2_eip.public_ip}"]
  records = ["${lookup(data.terraform_remote_state.customer_network.jenkins2_env_eip_ips, var.environment)}"]
}
