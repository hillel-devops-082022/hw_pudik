provider "aws" {
	region = var.aws_region
	shared_credentials_file = "$HOME/.aws/credentials"
  	profile = "default"
}

variable "aws_region" {
	default = "us-west-2"
}

variable "cidr" {
	default = "10.10.0.0/16"
}
variable "cidr_public" {
	default = ["10.10.10.0/24"]
}
variable "cidr_private" {
	default = ["10.10.20.0/24"]
}

variable "tags" {
	type = map(any)
	default = {
		Team = "hillel devops"
		Project = "vpc"
		Environment = "dev"
	}
}

module "vpc" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git"

  name = "my-vpc"
  cidr = var.cidr

  azs             = ["us-west-2a","us-west-2b","us-west-2c","us-west-2d"]
  private_subnets = var.cidr_private
  public_subnets  = var.cidr_public

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = var.tags

}
