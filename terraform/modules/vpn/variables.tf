variable "availability_zone" {}

variable "vpc_id" {}

variable "server_public_key" {}

variable "servers_private_key" {}

variable "subnet_id" {}

variable "server_username" {
  description = "Admin Username to access server"
  type        = string
  default     = "openvpn"
}

variable "server_password" {
  description = "Admin Password to access server"
  type        = string
  default     = "password"
}