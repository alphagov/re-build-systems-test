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

variable "hostname_suffix" {
  description = "Main domain name for new Jenkins instances, e.g. example.com"
  type        = "string"
}

variable "team_name" {
  description = "Name of your team. This is used to construct the DNS name for your Jenkins instances"
  type        = "string"
}
