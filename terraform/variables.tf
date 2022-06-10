# network variables:
####################
variable "availability_zone" {
   default = ["us-west-2a", "us-west-2b"] 
  }
 

variable "region" {
  description = "AWS region for VMs"
  default = "us-west-2"
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



## ssh key variables
####################


variable "jenkins_key_pair" {
  description = "jenkins key pair"
  type = string
  default = "jenkins_key"
}


variable "jenkins_private_key" {
  description = "Public jenkins key"
  type = string
  default = "keys/jenkins_key.pub"
}



variable "project_key_path" {
  description = "Path to private project key"
  type = string
  default = "/keys/project.pem"
}

variable "project_public_path" {
  description = "Path to public project key"
  type = string
  default = "/keys/project.pub"
}

variable "key_pair_names" {
  description = "EC2 Key pair names, "
  type = list(string)
  #default = ["project"]
  default = ["consul_key", "jenkins_key", "bastion_key"]
}
