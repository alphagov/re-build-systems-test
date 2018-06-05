variable "aws_az" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "subdomain" {
  description = "Subdomain"
  type        = "string"
}

variable "top_level_domain_name" {
  description = "Top Level Domain name"
  type        = "string"
  default     = "build.gds-reliability.engineering"
}
