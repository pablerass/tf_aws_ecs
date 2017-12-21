output "vpc_id" {
  value = "${data.aws_subnet.target.vpc_id}"
}

output "cluster_name" {
  value = "${var.cluster}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.main.id}"
}

output "lb_arn" {
  value = "${aws_alb.ecs.arn}"
}

output "lb_name" {
  value = "${aws_alb.ecs.name}"
}

output "lb_listener_arn" {
  value = "${aws_alb_listener.ecs.arn}"
}

output "autoscaling_group_id" {
  value = "${aws_autoscaling_group.ecs_instance.id}"
}
