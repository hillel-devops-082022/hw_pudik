provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow 80 and 443 inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "tcp_80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }
  ingress {
    description = "tcp_443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }
  ingress {
    description = "tcp_22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr вашего public ip
    cidr_blocks = [
      "93.72.200.52/32",
      data.aws_vpc.default.cidr_block
    ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "web"
  }
}

resource "aws_instance" "srv" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  count         = var.instance_count
  tags          = var.tags
  # Ваш aws key_pair
  key_name      = "my-aws-key-2"
  vpc_security_group_ids = [aws_security_group.web.id]
}

resource "aws_elb" "elb" {
  name               = "ec2elb"
  availability_zones = aws_instance.srv[*].availability_zone

  dynamic "listener" {
    for_each = ["80", "443"]
    content {
      instance_port     = listener.value
      instance_protocol = "http"
      lb_port           = listener.value
      lb_protocol       = "http"
    }
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }
  instances                   = aws_instance.srv[*].id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = var.tags
}
