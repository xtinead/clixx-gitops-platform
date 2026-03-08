variable "aws_region" { type = string }
variable "project"    { type = string }
variable "env"        { type = string }

variable "cluster_name" { type = string }
variable "cluster_version" { type = string }

variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs"  { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
