data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    cluster_name = "${var.cluster}"
  }
}

resource "aws_security_group" "ecs_instance" {
  name   = "ecs-${var.cluster}-instance"
  vpc_id = "${data.aws_subnet.target.vpc_id}"

  tags = "${var.tags}"
}

# We separate the rules from the aws_security_group because then we can manipulate the 
# aws_security_group outside of this module
resource "aws_security_group_rule" "ecs_instsance_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ecs_instance.id}"
}

resource "aws_security_group_rule" "ecs_container_ports" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.ecs_lb.id}"
  security_group_id        = "${aws_security_group.ecs_instance.id}"
}

resource "aws_security_group_rule" "ecs_container_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["${var.admin_cidrs}"]
  security_group_id = "${aws_security_group.ecs_instance.id}"
}

resource "aws_launch_configuration" "ecs_instance" {
  name_prefix          = "ecs-${var.cluster}"
  image_id             = "${data.aws_ami.ecs.id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.ecs_instance.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  user_data            = "${data.template_file.user_data.rendered}"
  key_name             = "${var.key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_instance" {
  name                 = "ecs-${var.cluster}"
  max_size             = "${var.max_cluster_size}"
  min_size             = "${var.min_cluster_size}"
  desired_capacity     = "${var.desired_cluster_capacity}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.ecs_instance.id}"
  vpc_zone_identifier  = ["${var.private_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "ecs-${var.cluster}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Cluster"
    value               = "${var.cluster}"
    propagate_at_launch = "true"
  }
}