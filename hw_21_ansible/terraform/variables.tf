variable "instance_type" {
  default = "t2.micro"
}

variable "instance_count" {
  default = 2
}

variable "aws_region" {
  default = "us-west-2"
}

variable "tags" {
  type = map(string)
  default = {
    Team    = "hillel_devops"
    Project = "realworld"
  }
}

variable "private_key_path" {
  type        = string
  description = "Path to SSH private key"
  default     = "./my-aws-key-pair.pem"
}
