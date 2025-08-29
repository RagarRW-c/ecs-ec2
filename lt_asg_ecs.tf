# AMI ECS-Optimized AL2 with SSM Parameter Store

data "aws_ssm_parameter" "ecs_al2" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

locals {
  ecs_ami_id = jsondecode(data.aws_ssm_parameter.ecs_al2.value).image_id
}

resource "aws_security_group" "ecs_instances" {
  name   = "${var.project_name}-ecs-instances-sg"
  vpc_id = aws_vpc.main.id

  #Inbound not needed for tasks in awsvpc
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
  Name = "${var.project_name}-ecs-instances-sg" })
}


#User data: connect cluster, turn on ENI
locals {
  ecs_user_data = <<EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.this.name}" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_TASK_ENI=true" >> /etc/ecs/ecs.config
  EOF
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project_name}-lt-ecs"
  image_id      = local.ecs_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }
  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  user_data = base64encode(local.ecs_user_data)
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name = "${var.project_name}-ecs-instance"
    })
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                  = "${var.project_name}-ecs-asg"
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  vpc_zone_identifier   = [for s in aws_subnet.private : s.id]
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.ecs.id
    version = aws_launch_template.ecs.latest_version
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-instance"
    propagate_at_launch = true
  }
}