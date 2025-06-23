provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "jeffops" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jeffops_sg.id]
  user_data              = file("user_data.sh")

  tags = {
    Name = "jeffops-instance"
  }
}

resource "aws_security_group" "jeffops_sg" {
  name        = "jeffops-sg"
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.jeffops.id
}

output "instance_public_ip" {
  description = "The public IP of the JeffOps instance"
  value       = aws_eip.ip.public_ip
}
