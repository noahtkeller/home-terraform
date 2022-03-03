resource aws_vpc primary_vpc {
  cidr_block = "172.31.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main vpc"
  }
}

resource aws_default_security_group allow_all {
  vpc_id = aws_vpc.primary_vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow all traffic"
  }
}
