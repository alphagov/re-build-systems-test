# GDS IP's
allowed_ips = [
  "85.133.67.244/32",
  "213.86.153.212/32",
  "213.86.153.213/32",
  "213.86.153.214/32",
  "213.86.153.235/32",
  "213.86.153.236/32",
  "213.86.153.237/32",
]

aws_az = "eu-west-1a"

aws_profile = "re-build-systems"

custom_groovy_script = "./files/custom-script.groovy"

aws_region = "eu-west-1"

environment = "verify"

jenkins_admin_users_github_usernames = [
  "daniele-occhipinti",
  "JonathanHallam",
]

github_organisations = [
  "alphagov"
]

gitrepo = "https://github.com/alphagov/terraform-aws-re-build-jenkins.git"

gitrepo_branch = "master"

hostname_suffix = "build.gds-reliability.engineering"

server_instance_type = "t2.small"

server_name = "jenkins"

server_root_volume_size = "40"

ssh_public_key_file = "key.pub"

team_name = "daniele-20"

worker_instance_type = "t2.medium"

worker_name = "worker"

worker_root_volume_size = "50"

append_worker_user_data = "cloud-init/worker_specific_cloud_init.sh"

append_server_user_data = "cloud-init/server_specific_cloud_init.sh"
