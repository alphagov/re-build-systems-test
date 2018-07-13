variable "aws_az" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "team_name" {
  description = "Team Name"
  type        = "string"
}

variable "top_level_domain_name" {
  description = "Top Level Domain name"
  type        = "string"
  default     = "build.gds-reliability.engineering"
}
