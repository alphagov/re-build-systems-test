module "jenkins2_sg_cloudflare" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.22.0"

  name        = "jenkins2_sg_cloudflare_${var.team_name}_${var.environment}"
  description = "Jenkins2 Security Group Allowing HTTP - Cloudflare"
  vpc_id      = "${module.jenkins2_vpc.vpc_id}"

  ingress_cidr_blocks = ["${var.cloudflare_ips}"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
}
