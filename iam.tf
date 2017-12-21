resource "aws_iam_role" "ecs_instance" {
  name = "ecs_instance_${var.cluster}"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs_${var.cluster}"
  path = "/ecs/"
  role = "${aws_iam_role.ecs_instance.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ec2" {
  role       = "${aws_iam_role.ecs_instance.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
