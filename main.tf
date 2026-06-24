provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "k3s_sg" {
  name = "k3s-sg"

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["157.49.184.225/32"]
  }

  ingress {
    description = "K3s API"

    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"

    cidr_blocks = ["157.49.184.225/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.k3s_sg.id
  ]

  tags = {
    Name = "k3s-server"
  }
}