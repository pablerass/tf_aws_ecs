variable "owner" {
  description = "Resources owner"
}

variable "key_pair" {
  description = "Instances AWS key name"
}

variable "cluster" {
}

variable "min_cluster_size" {
}

variable "max_cluster_size" {
}

variable "desired_cluster_capacity" {
}

variable "private_subnet_ids" {
  type = "list"
}

variable "lb_subnet_ids" {
  type = "list"
}

variable "instance_type" {
}
