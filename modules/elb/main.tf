data "template_file" "jenkins_template" {
  template = "${file("${path.module}/jenkins-setup.sh")}"
  vars = {
    efs_dns_name = "${var.efs_dns_name.dns_name}"
  }
}

resource "aws_launch_template" "jenkins_launch_template" {
  name_prefix = "${var.name}"
  image_id = var.image_id
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = [var.sg.jenkins_sg]
  key_name = var.key_pair
  user_data = "${base64encode(data.template_file.jenkins_template.rendered)}"
}

resource "aws_lb_target_group" "target_gr" {
  name = "${var.name}-target-gr"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc.vpc_id
  target_type = "instance"
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "403"
    interval            = 15
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 10
  }
}

resource "aws_autoscaling_group" "asg" {
  depends_on = [var.efs_mount_target]
  name                = "${var.name}-asg"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = var.vpc.public_subnet
  target_group_arns = [aws_lb_target_group.target_gr.arn]
  launch_template {
    id      = aws_launch_template.jenkins_launch_template.id
  }
  tag {
    key                 = "Name"
    value               = "${var.name}-jenkins"
    propagate_at_launch = true
  }
}

resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg.jenkins_sg]
  subnets            = var.vpc.public_subnet
  enable_deletion_protection = false
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_gr.id
  }
}