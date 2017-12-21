data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*.g-amazon-ecs-optimized"]
  }

  owners = ["591542846629"]
}

data "aws_subnet" "target" {
    id = "${var.private_subnet_ids[0]}"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.cluster}"
}
