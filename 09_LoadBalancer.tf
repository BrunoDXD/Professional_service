resource "aws_lb" "this" {
  name               = "lb-wordpress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_wordpress.id]
  subnets            = [aws_subnet.this["pub_a"].id, aws_subnet.this["pub_b"].id]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

 resource "aws_lb_target_group" "this" {
   name     = "learn-asg-terramino"
   port     = 80
   protocol = "HTTP"
   vpc_id   = aws_vpc.this.id

   health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
 }

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  alb_target_group_arn   = aws_lb_target_group.this.arn
}
