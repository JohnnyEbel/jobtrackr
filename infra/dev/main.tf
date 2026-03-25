# SG für jobtrackr
resource "aws_security_group" "jobtrackr_sg" {
  name = "jobtrackr-sg"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["92.208.116.143/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ubuntu ami
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "jobtrackr" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.jobtrackr_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              
              systemctl start docker
              sleep 10

              usermod -aG docker ubuntu

              docker pull ghcr.io/${var.ghcr_user}/jobtrackr:latest
              
              docker run -d -p 5000:5000 ghcr.io/${var.ghcr_user}/jobtrackr:latest
              EOF

  tags = {
    Name = "jobtrackr-instance"
  }
}