resource "aws_launch_template" "example" {
  name_prefix   = "example"
  image_id      = "ami-0d53d72369335a9d6"
  instance_type = "t2.nano"
}

resource "aws_autoscaling_group" "example" {
  availability_zones = ["us-west-1b"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
 
  load_balancers = [aws_elb.example.name]
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}

