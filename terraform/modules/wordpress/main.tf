# Public subnets
resource "aws_subnet" "wordpress_public_a" {
  vpc_id            = var.aws_vpc_wordpress_vpc_id
  cidr_block        = "10.128.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = "true"
}

resource "aws_subnet" "wordpress_public_b" {
  vpc_id            = var.aws_vpc_wordpress_vpc_id
  cidr_block        = "10.128.2.0/24"
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = "true"
}

resource "aws_route_table_association" "igw_route_table_association_a" {
 subnet_id      = aws_subnet.wordpress_public_a.id
 route_table_id = var.igw_route_table_id
}

resource "aws_route_table_association" "igw_route_table_association_b" {
 subnet_id      = aws_subnet.wordpress_public_b.id
 route_table_id = var.igw_route_table_id
}

# Wordpress instances
resource "aws_security_group" "wordpress-sg" {
  name    = "wordpress-sg"
  vpc_id  = var.aws_vpc_wordpress_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress_a" {
  ami               = var.ami
  instance_type     = var.wordpress_instance_type
  vpc_security_group_ids   = [ aws_security_group.wordpress-sg.id ]
  subnet_id         = aws_subnet.wordpress_public_a.id
  user_data_base64  = base64encode(local.wp_install)
  key_name = var.key_name

  tags = {
    Name = "Wordpress Instance A"
  }

  root_block_device {
    delete_on_termination = true
    volume_size = 8
  }
}

resource "aws_instance" "wordpress_b" {
  ami               = var.ami
  instance_type     = var.wordpress_instance_type
  vpc_security_group_ids   = [ aws_security_group.wordpress-sg.id ]
  subnet_id         = aws_subnet.wordpress_public_b.id
  user_data_base64  = base64encode(local.wp_install)
  key_name = var.key_name

  tags = {
    Name = "Wordpress Instance B"
  }

  root_block_device {
    delete_on_termination = true
    volume_size = 8
  }
}

# Load balancer
resource "aws_lb_target_group" "wordpress-lb-tg" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_wordpress_vpc_id

  depends_on  = [
    aws_lb.wordpress-lb
  ]
}

resource "aws_lb_target_group_attachment" "wordpress-tg-attachment-a" {
  target_group_arn  = aws_lb_target_group.wordpress-lb-tg.arn
  target_id         = aws_instance.wordpress_a.id
  port              = 80
}

resource "aws_lb_target_group_attachment" "wordpress-tg-attachment-b" {
  target_group_arn  = aws_lb_target_group.wordpress-lb-tg.arn
  target_id         = aws_instance.wordpress_b.id
  port              = 80
}

resource "aws_security_group" "public-elb-sg" {
  name    = "wordpress-elb-sg"
  vpc_id  = var.aws_vpc_wordpress_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "wordpress-lb" {
  name               = "wordpress-lb"
  internal           = false
  security_groups    = [aws_security_group.public-elb-sg.id]
  subnets            = [aws_subnet.wordpress_public_a.id,aws_subnet.wordpress_public_b.id]
}

resource "aws_lb_listener" "wordpress-lb-listener" {
  load_balancer_arn = aws_lb.wordpress-lb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-lb-tg.arn
  }
}

# NAT gateways for the database
resource "aws_eip" "nat_gateway_eip_a" {
  vpc = true
}

resource "aws_eip" "nat_gateway_eip_b" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat_gateway_eip_a.id
  subnet_id = aws_subnet.wordpress_public_a.id
}

resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = aws_eip.nat_gateway_eip_b.id
  subnet_id = aws_subnet.wordpress_public_b.id
}

resource "aws_route_table" "nat_gw_a_rt" {
  vpc_id = var.aws_vpc_wordpress_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }
}

resource "aws_route_table" "nat_gw_b_rt" {
  vpc_id = var.aws_vpc_wordpress_vpc_id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_b.id
  }
}

output "nat_route_table_a_id" {
  value = aws_route_table.nat_gw_a_rt.id
}

output "nat_route_table_b_id" {
  value = aws_route_table.nat_gw_b_rt.id
}

output "elb-dns-name" {
  value = "${aws_lb.wordpress-lb.dns_name}"
}

