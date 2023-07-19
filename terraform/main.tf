terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "credentials" {
  source                                   = "./modules/credentials"
  key_name                                 = var.key_name
}

module "general" {
  source     = "./modules/general"
  aws_region = var.aws_region
}

module "wordpress" {
  source                                   = "./modules/wordpress"
  aws_vpc_wordpress_vpc_id                 = module.general.aws_vpc_wordpress_vpc_id
  aws_region                               = var.aws_region
  igw_route_table_id                       = module.general.igw_route_table_id
  ami                                      = var.ami
  wordpress_instance_type                  = var.wordpress_instance_type
  key_name                                 = var.key_name
  db_host                                  = module.database.database_host
  db_name                                  = var.db_name
  db_user                                  = var.db_user
  db_pass                                  = var.db_pass
  wp_user                                  = var.wp_user
  wp_pass                                  = var.wp_pass
}

module "database" {
  source                                   = "./modules/database"
  aws_vpc_wordpress_vpc_id                 = module.general.aws_vpc_wordpress_vpc_id
  igw_route_table_id                       = module.general.igw_route_table_id
  nat_route_table_a_id                     = module.wordpress.nat_route_table_a_id
  nat_route_table_b_id                     = module.wordpress.nat_route_table_b_id
  ami                                      = var.ami
  database_instance_type                   = var.database_instance_type
  aws_region                               = var.aws_region
  db_name                                  = var.db_name
  db_user                                  = var.db_user
  db_pass                                  = var.db_pass
  key_name                                 = var.key_name
}

output "wordpress_lb" {
  value = "http://${module.wordpress.elb-dns-name}/"
}

