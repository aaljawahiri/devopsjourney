terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    region  = "eu-west-2"
    profile = "default"
    key     = "s3state"
    bucket  = "tfstates3backend"
  }
}