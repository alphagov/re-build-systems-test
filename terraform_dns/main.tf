terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.11.0"
  region  = "${var.aws_region}"

  # shared_credentials_file = "~/.aws/credentials"
  profile = "${var.aws_profile}"
}

resource "aws_route53_zone" "primary_zone" {
<<<<<<< HEAD
  name = "${var.team_name}.${var.top_level_domain_name}"

  tags {
    ManagedBy = "terraform"
    Name      = "${var.team_name}.${var.top_level_domain_name}"
  }

  lifecycle {
    prevent_destroy = false 
  }
}

resource "aws_eip" "jenkins2_eips" {
  count = "${length(var.team_environments)}"
  vpc   = false

  lifecycle {
    prevent_destroy = false 
  }

  tags = {
    ManagedBy = "terraform"
    Name      = "jenkins2_eips_${element(var.team_environments, count.index)}_${var.team_name}_${var.top_level_domain_name}"
=======
  name = "${var.subdomain}.${var.top_level_domain_name}"

  tags {
    ManagedBy = "terraform"
    Name      = "${var.subdomain}.${var.top_level_domain_name}"
>>>>>>> Add ability to manange DNS and EIP in a seperate terraform state file
  }
}
