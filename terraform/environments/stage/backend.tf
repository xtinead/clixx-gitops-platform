terraform {
  backend "s3" {
    # Portfolio-safe placeholder. Fill with your real values locally.
    bucket         = "REPLACE_ME-terraform-state"
    key            = "clixx/stage/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_ME-terraform-locks"
    encrypt        = true
  }
}
