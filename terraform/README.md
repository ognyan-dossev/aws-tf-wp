# Terraform deployment of Wordpress

VPC CIDR 10.128.0.0/16
All instances are in a public network, auto-generated rsa key
2x Wordpress + ELB + TG
1x Database

## Manually defined (sensitive) variables
db_user
db_pass
wp_user
wp_pass

## Connectivity
Uncomment map_public_ip_on_launch to be able to access the instances (not recommended for productional environments!).
SSH key is automatically provisioned with `terraform apply` and written to .ssh folder.



