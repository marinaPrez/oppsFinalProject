variable "availability_zone" {}

variable "vpc_id" {}

variable "server_public_key" {}

variable "servers_private_key" {}

variable "subnet_id" {}

variable "ami" {}

variable "region" {}

variable "consul_iam_instance_profile" {}

variable "consul_security_group" {}



/* variable "ami" {
  description = "ami (ubuntu 18) to use - based on region"
  default = {
    "us-east-1" = "ami-00ddb0e5626798373"
    "us-east-2" = "ami-0dd9f0e7df0f0a138"
    "us-west-2" = "ami-0ac73f33a1888c64a" 
  }
} */




/* variable "region" {
  description = "AWS region for VMs"
  default = "us-west-2"
} */