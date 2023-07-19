resource "aws_vpc" "wordpress_vpc" {
  cidr_block = "10.128.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Wordpress VPC"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.wordpress_vpc.id  
}

resource "aws_route_table" "igw_route_table" {
 vpc_id = aws_vpc.wordpress_vpc.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gateway.id
 }
}

output "aws_vpc_wordpress_vpc_id" {
  value = aws_vpc.wordpress_vpc.id
}

output "igw_route_table_id" {
  value = aws_route_table.igw_route_table.id
}

