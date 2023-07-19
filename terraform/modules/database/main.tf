resource "aws_subnet" "database_private" {
  vpc_id            = var.aws_vpc_wordpress_vpc_id
  cidr_block        = "10.128.3.0/24"
  availability_zone = "${var.aws_region}a"
  # map_public_ip_on_launch = "true"
}

resource "aws_route_table_association" "nat_route_table_association_database_a" {
 subnet_id      = aws_subnet.database_private.id
 route_table_id = var.nat_route_table_a_id
}

# resource "aws_route_table_association" "nat_route_table_association_database_b" {
#  subnet_id      = aws_subnet.database_private.id
#  route_table_id = var.nat_route_table_b_id # !!!
# }

resource "aws_security_group" "database-sg" {
  name    = "database-sg"
  vpc_id  = var.aws_vpc_wordpress_vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "database" {
  ami               = var.ami
  instance_type     = var.database_instance_type
  user_data_base64  = base64encode(local.mysql_install)
  subnet_id         = aws_subnet.database_private.id
  vpc_security_group_ids   = [ aws_security_group.database-sg.id ]
  key_name          = var.key_name

  root_block_device {
    delete_on_termination = true
    volume_size = 8
  }

  tags = {
    Name = "Wordpress database"
  }
}

output "database_host" {
  value = aws_instance.database.private_ip
}

