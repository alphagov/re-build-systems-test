module "jenkins2_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.30.0"

  name = "jenkins2_vpc_${var.team_name}_${var.environment}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_az}"]
  public_subnets  = ["${var.public_subnet}"]

  # enable_nat_gateway = true
  # single_nat_gateway = true

  tags = {
    Environment = "${var.environment}"
    ManagedBy   = "terraform"
    Name        = "jenkins2_vpc_${var.team_name}_${var.environment}"
    Team        = "${var.team_name}"
  }
}
