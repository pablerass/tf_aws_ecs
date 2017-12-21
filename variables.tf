variable "internal" {
  default = "false"
}

variable "protocol" {
  default = "HTTP"
}

variable "certificate_arn" {
  default = ""
}

variable "module" {
  description = "Terraform module"

  default = "tf_aws_ecs"
}

variable "admin_cidrs" {
  description = "Adminitration CIDRs for remote access"
  default = []
}

variable "admin_sgs" {
  description = "Administrative SGs for remote access"
  type        = "list"
  default     = []
}

variable "tags" {
  description = "Resources tags"
  default     = {}
}
