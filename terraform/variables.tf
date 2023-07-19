variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "wordpress_instance_count" {
  type        = number
  default     = 2
  description = "Wordpress instances count"
}

variable "wordpress_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "database_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "db_name" {
  type    = string
  default = "wordpress"
}

variable "db_user" {
  type      = string
  sensitive = true
  # default = "dbadmin"
}

variable "db_pass" {
  type      = string
  sensitive = true
  # default = "dbpass"
}

variable "wp_user" {
  type      = string
  sensitive = true
  # default = "wpadmin1"
}

variable "wp_pass" {
  type      = string
  sensitive = true
  # default = "wppass1"
}

variable "ami" {
  type    = string
  default = "ami-01dd271720c1ba44f" #Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
}

variable "key_name" {
  type = string
  default = "wp_aws_key"
}
