variable "allowed_ips" {
  description = "A list of IP addresses permitted to access (via SSH & HTTPS) the EC2 instances created that are running Jenkins"
  type        = "list"
}

variable "aws_az" {
  description = "Single availability zone to place master and worker instances in (a,b,c)"
  type        = "string"
  default     = "a"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = "string"
}

variable "aws_region" {
  description = "AWS region"
  type        = "string"
}

variable "custom_groovy_script" {
  description = "Path to custom groovy script to run at end of initial jenkins configuration"
  type        = "string"
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g. production, test, ci). This is used to construct the DNS name for your Jenkins instances"
  type        = "string"
}

variable "github_admin_users" {
  description = "List of Github admin users"
  type        = "list"
  default     = []
}

variable "github_client_id" {
  description = "Your Github Auth client ID"
  type        = "string"
  default     = ""
}

variable "github_client_secret" {
  description = "Your Github Auth client secret"
  type        = "string"
  default     = ""
}

variable "github_organisations" {
  description = "List of Github organisations and teams that users must be a member of to allow HTTPS login to master"
  type        = "list"
  default     = []
}

variable "gitrepo" {
  description = "Git repo that hosts Dockerfile"
  type        = "string"
}

variable "gitrepo_branch" {
  description = "Branch of git repo that hosts Dockerfile"
  type        = "string"
  default     = "master"
}

variable "hostname_suffix" {
  description = "Main domain name for new Jenkins instances, e.g. example.com"
  type        = "string"
}

variable "server_instance_type" {
  description = "This defines the default master server EC2 instance type"
  type        = "string"
  default     = "t2.small"
}

variable "server_name" {
  description = "Hostname of the jenkins2 master"
  type        = "string"
  default     = "jenkins2"
}

variable "server_root_volume_size" {
  description = "Size of the Jenkins Server root volume (GB)"
  type        = "string"
  default     = "50"
}

variable "ssh_public_key_file" {
  description = "Location of public key used to access the server instances"
  type        = "string"
}

variable "team_name" {
  description = "Name of your team. This is used to construct the DNS name for your Jenkins instances"
  type        = "string"
}

variable "worker_instance_type" {
  description = "This defines the default worker server EC2 instance type"
  type        = "string"
  default     = "t2.medium"
}

variable "worker_name" {
  description = "Name of the jenkins2 worker"
  type        = "string"
  default     = "worker"
}

variable "worker_root_volume_size" {
  description = "Size of the Jenkins Worker root volume (GB)"
  type        = "string"
  default     = "50"
}

variable "append_worker_user_data" {
  description = "File, in bash format, containing a list of commands to be run at the end of the default user_data cloud-init file for the worker instances"
  type        = "string"
  default     = ""
}

variable "append_server_user_data" {
  description = "File, in bash format, containing a list of commands to be run at the end of the default user_data cloud-init file for the server instance(s)"
  type        = "string"
  default     = ""
}
