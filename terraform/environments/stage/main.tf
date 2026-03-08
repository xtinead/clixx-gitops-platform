locals {
  name = "${var.project}-${var.env}"
}

module "vpc" {
  source = "../../modules/vpc"
  # In a portfolio-safe repo, this module may be interface-only.
  # In your private repo, this is fully implemented.
}

module "eks" {
  source = "../../modules/eks"
}

module "iam" {
  source = "../../modules/iam"
}

module "alb" {
  source = "../../modules/alb"
}
