aws_region = "us-east-1"
project    = "clixx"
env        = "stage"

cluster_name    = "clixx-stage"
cluster_version = "1.29"

vpc_cidr = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
