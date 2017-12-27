resource "aws_alb" "ecs" {
  name            = "ecs-${var.cluster}"
  internal        = "${var.internal}"
  security_groups = ["${aws_security_group.ecs_lb.id}"]
  subnets         = ["${var.lb_subnet_ids}"]

  enable_deletion_protection = false

  tags {
    Ecosystem = "${var.ecosystem}"
  }
}

resource "aws_alb_listener" "ecs" {
  load_balancer_arn = "${aws_alb.ecs.arn}"
  port              = "${var.protocol == "HTTP" ? "80" : "443"}"
  protocol          = "${var.protocol}"

  ssl_policy        = "${var.protocol == "HTTP" ? "" : "ELBSecurityPolicy-2015-05"}"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs_default.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "ecs_default" {
  name     = "ecs-${var.cluster}-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_subnet.target.vpc_id}"
}

resource "aws_security_group" "ecs_lb" {
  name   = "ecs-${var.cluster}-alb"
  vpc_id = "${data.aws_subnet.target.vpc_id}"

  tags {
    Ecosystem = "${var.ecosystem}"
    Cluster   = "${var.cluster}"
  }
}

resource "aws_security_group_rule" "ecs_lb_instances" {
  type                     = "egress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.ecs_instance.id}"
  security_group_id        = "${aws_security_group.ecs_lb.id}"
}

resource "aws_security_group_rule" "ecs_lb_ingress" {
  type              = "ingress"
  from_port         = "${var.protocol == "HTTP" ? "80" : "443"}"
  to_port           = "${var.protocol == "HTTP" ? "80" : "443"}"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ecs_lb.id}"
}

resource "aws_route53_record" "ecs_lb" {
  count   = "${var.route53_zone_id == "" ? 0 : 1}"

  zone_id = "${var.route53_zone_id}"
  name    = "ecs-${var.cluster}"
  type    = "A"

  alias {
    name = "${aws_alb.ecs.dns_name}"
    zone_id = "${aws_alb.ecs.zone_id}"
    evaluate_target_health = false
  }
}
