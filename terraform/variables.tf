# #### AWS preferences ####

variable "allowed_ips" {
  type = "list"
}

variable "aws_az" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "cloudflare_ips" {
  description = "Allowed Cloudflare IP Addresses"
  type        = "list"

  default = [
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "104.16.0.0/12",
    "108.162.192.0/18",
    "131.0.72.0/22",
    "141.101.64.0/18",
    "162.158.0.0/15",
    "172.64.0.0/13",
    "173.245.48.0/20",
    "188.114.96.0/20",
    "190.93.240.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
  ]
}

variable "instance_type" {
  type        = "string"
  description = "This defines the default (aws) instance type."
  type        = "string"
  default     = "t2.small"
}

variable "private_subnet" {
  type    = "string"
  default = "10.0.1.0/24"
}

variable "public_subnet" {
  type    = "string"
  default = "10.0.101.0/24"
}

# #### Team preferences ####

variable "environment" {
  description = "Environment (test, staging, production, etc)"
  type        = "string"
}

variable "product" {
  description = "The name of the product"
  type        = "string"
}

# #### Github preferences ####

variable "github_admin_users" {
  description = "List of Github admin users."
  type        = "list"
  default     = []
}

variable "github_client_id" {
  description = "Your Github client Id"
  type        = "string"
  default     = ""
}

variable "github_client_secret" {
  description = "Your Github client secret"
  type        = "string"
  default     = ""
}

variable "github_organisations" {
  description = "List of Github organisations."
  type        = "list"
  default     = []
}

variable "gitrepo" {
  type = "string"
}

# #### Docker and Jenkins preferences ####

variable "dockerversion" {
  description = "Docker version to install"
  type        = "string"
}

variable "hostname_suffix" {
  type = "string"
}

variable "server_name" {
  description = "Name of the jenkins2 server"
  type        = "string"
}

variable "server_persistent_storage_size" {
  description = "Size for the persistent storage for the Jenkins Server (GB)"
  type        = "string"
  default     = "50"
}

variable "server_root_volume_size" {
  description = "Size of the Jenkins Server root volume (GB)"
  type        = "string"
  default     = "50"
}

variable "ubuntu_release" {
  description = "Which version of ubuntu to install on Jenkins Server"
  type        = "string"
}

variable "worker_instance_type" {
  description = "This defines the default (aws) instance type."
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
