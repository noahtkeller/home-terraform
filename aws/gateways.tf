resource aws_internet_gateway primary_igateway {
  vpc_id = aws_vpc.primary_vpc.id
}