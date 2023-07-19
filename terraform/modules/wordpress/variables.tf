variable "aws_vpc_wordpress_vpc_id" {
  type = string
}

variable "aws_region" {
    type    = string
    default = "eu-west-1"
}

variable "igw_route_table_id" {
  type = string  
}

variable "ami" {
  type    = string
  default = "ami-01dd271720c1ba44f" #Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
}

variable "wordpress_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
}

variable "db_host" {
  type    = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type        = string
  sensitive   = true
}

variable "db_pass" {
  type        = string
  sensitive   = true
}

variable "wp_user" {
  type        = string
  sensitive   = true
}

variable "wp_pass" {
  type        = string
  sensitive   = true
}

variable "blogpost" {
  default = <<-EOT
Namespaces are a feature of the Linux kernel that partitions kernel resources such that one set of processes sees one set of resources while another set of processes sees a different set of resources. The feature works by having the same namespace for these resources in the various sets of processes, but those names referring to distinct resources. Examples of resource names that can exist in multiple spaces, so that the named resources are partitioned, are process IDs, hostnames, user IDs, file names, and some names associated with network access, and interprocess communication.

Namespaces are a fundamental aspect of containers on Linux.

The term "namespace" is often used for a type of namespace (e.g. process ID) as well for a particular space of names.

A Linux system starts out with a single namespace of each type, used by all processes. Processes can create additional namespaces and join different namespaces.
EOT
}

variable "blogpost_title" {
  default = "Linux namespaces"
}

locals {
  wp_install = <<EOF
#!/bin/bash
sudo apt update
sudo apt install -y php libapache2-mod-php php-mysql mysql-client apache2 sendmail
sudo ufw allow in "Apache"
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
cd /var/www/html
sudo rm -f index.html
sudo wp core download --allow-root
sudo wp core config --dbhost=${var.db_host} --dbname=${var.db_name} --dbuser=${var.db_user} --dbpass=${var.db_pass} --allow-root

# stop here if post '${var.blogpost_title}' exists
[[ $(sudo wp post list --allow-root | grep "${var.blogpost_title}" | wc -l) > 0 ]] && exit 0

sudo wp core install --url=${aws_lb.wordpress-lb.dns_name} --title="Wordpress Blog" --admin_name=${var.wp_user} --admin_password=${var.wp_pass} --admin_email=${var.wp_user}@testwordpress.com --allow-root --skip-email || true
echo "${var.blogpost}" >/tmp/blogpost.txt
sudo wp post create /tmp/blogpost.txt --post_title='${var.blogpost_title}' --post_status=publish --allow-root
sudo wp post delete 1 2 --allow-root || true
EOF
}

