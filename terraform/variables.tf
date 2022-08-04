# network variables:
####################
variable "availability_zone" {
   default = ["us-east-2a", "us-east-2b"] 
  }
 

variable "region" {
  description = "AWS region for VMs"
  default = "us-east-2"
}

variable "public_subnet" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24"]
  }

variable "private_subnet" {
  type    = list(string)
  default = ["10.0.6.0/24", "10.0.7.0/24"]
  }

variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}


variable "ami" {
  description = "ami (ubuntu 18) to use - based on region"
  default = {
    "us-east-1" = "ami-00ddb0e5626798373"
    "us-east-2" = "ami-0dd9f0e7df0f0a138"
    "us-west-2" = "ami-0ac73f33a1888c64a" 
  }
}

## ssh key variables
####################

variable "key_pair_names" {
  description = "EC2 Key pair names, "
  type = list(string)
  default = ["consul_key", "jenkins_key", "vpn_key", "monitor_key","logging_key" ]
}
