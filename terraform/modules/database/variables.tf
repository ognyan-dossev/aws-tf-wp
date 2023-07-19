variable "aws_region" {
  type = string
  default = "eu-west-1"
}

variable "ami" {
  type    = string
  default = "ami-01dd271720c1ba44f" #Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
}

variable "aws_vpc_wordpress_vpc_id" {
  type    = string
  default = ""
}

variable "database_instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
}

variable "db_name" {
}

variable "db_user" {
  sensitive = true
  type      = string
}

variable "db_pass" {
  sensitive = true
  type      = string
}

variable "igw_route_table_id" {
  type = string  
}

variable "nat_route_table_a_id" {
  type = string  
}

variable "nat_route_table_b_id" {
  type = string  
}

locals {
  mysql_install = <<EOF
#!/bin/bash
sudo apt-get update 
sudo apt-get install -y mysql-server
sudo ufw allow mysql
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

# echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${var.db_pass}';" | sudo mysql -u root

echo "CREATE DATABASE ${var.db_name};" | mysql -u root # --password=${var.db_pass}
echo "CREATE USER '${var.db_user}'@'%' IDENTIFIED WITH mysql_native_password BY '${var.db_pass}';" | sudo mysql -u root # --password=${var.db_pass}
echo "GRANT ALL PRIVILEGES ON ${var.db_name}.* TO '${var.db_user}'@'%' WITH GRANT OPTION;FLUSH PRIVILEGES;" | sudo mysql -u root # --password=${var.db_pass}

sudo crontab -l | { cat; echo "0 0 * * Sun /usr/bin/mysqlcheck -o wordpress -u root >> /var/log/optimize.log 2>&1"; } | sudo crontab - 
EOF
}

