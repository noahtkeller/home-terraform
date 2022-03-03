resource aws_subnet worker_subnet {
  vpc_id            = aws_vpc.primary_vpc.id
  # 172.31.0.0 through 172.31.0.15
  cidr_block        = "172.31.0.0/28"
  availability_zone = var.default-availability-zone

  tags = {
    Name = "worker subnet"
  }
}

resource aws_subnet master_subnet {
  vpc_id            = aws_vpc.primary_vpc.id
  # 172.31.0.16 through 172.31.0.31
  cidr_block        = "172.31.0.16/28"
  availability_zone = var.default-availability-zone

  tags = {
    Name = "master subnet"
  }
}

resource aws_default_route_table primary_route_table {
  default_route_table_id = aws_vpc.primary_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igateway.id
  }
}

resource aws_main_route_table_association primary_subnet_association {
  vpc_id = aws_vpc.primary_vpc.id
  route_table_id = aws_default_route_table.primary_route_table.id
}

resource aws_main_route_table_association secondary_subnet_association {
  vpc_id = aws_vpc.primary_vpc.id
  route_table_id = aws_default_route_table.primary_route_table.id
}
