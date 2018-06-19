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
  name = "${var.team_name}.${var.top_level_domain_name}"

  tags {
    ManagedBy = "terraform"
    Name      = "${var.team_name}.${var.top_level_domain_name}"
    Team      = "${var.team_name}"
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
    Team      = "${var.team_name}"
  }
}

resource "null_resource" "Instructions" {
  depends_on = ["aws_route53_zone.primary_zone"]

  provisioner "local-exec" {
    command = <<EOT
      echo "\n*****************************\n\nPlease send the following information to whichever team in your organisation looks after the domain name ${var.top_level_domain_name}: \n${var.team_name} = ['${join(".','", aws_route53_zone.primary_zone.name_servers)}.']\n\n*****************************"
    EOT
  }
}
