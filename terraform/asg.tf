locals {
  asg_jenkins2_extra_tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "ManagedBy"
      value               = "terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "jenkins2_asg-${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}"
      propagate_at_launch = true
    },
    {
      key                 = "Team"
      value               = "${var.team_name}"
      propagate_at_launch = true
    },
  ]
}

resource "aws_launch_configuration" "lc_jenkins2_server" {
  name          = "alc-${var.server_name}.${var.environment}.${var.team_name}.${var.hostname_suffix}-"
  image_id      = "${data.aws_ami.source.id}"
  instance_type = "${var.instance_type}"

  # associate_public_ip_address = true
  user_data = "${data.template_file.jenkins2_server_template.rendered}"
  key_name  = "jenkins2_key_${var.team_name}_${var.environment}"

  # vpc_security_group_ids      = ["${module.jenkins2_sg_server_internet_facing.this_security_group_id}", "${module.jenkins2_sg_server_private_facing.this_security_group_id}", "${module.jenkins2_sg_cloudflare.this_security_group_id}"]

  root_block_device = [{
    volume_size           = "${var.server_root_volume_size}"
    delete_on_termination = "true"
  }]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_jenkins2_server" {
  name_prefix = "asg-${var.server_name}-${var.environment}-${var.team_name}-"

  launch_configuration = "${aws_launch_configuration.lc_jenkins2_server.name}"

  #launch_template = {
  #  id      = "${aws_launch_template.lc_jenkins2_server.id}"
  #  version = "$$Latest"
  #}

  vpc_zone_identifier = ["${module.jenkins2_vpc.public_subnets}"]
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  lifecycle {
    create_before_destroy = true
  }
  tags = ["${local.asg_jenkins2_extra_tags}"]
}

resource "aws_elb" "elb_jenkins2_server" {
  name               = "elb-${var.server_name}-${var.environment}-${var.team_name}"
  availability_zones = ["eu-west-2a"]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_acm_certificate.tls_certificate.arn}"
  }

  #  health_check {
  #    healthy_threshold   = 2
  #    unhealthy_threshold = 2
  #    timeout             = 3
  #    target              = "HTTP:80/"
  #    interval            = 30
  #  }

  tags {
    Environment = "${var.environment}"
    ManagedBy   = "terraform"
    Name        = "jenkins2_elb_${var.team_name}_${var.environment}"
    Team        = "${var.team_name}"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg_jenkins2_server.id}"
  elb                    = "${aws_elb.elb_jenkins2_server.id}"
}
