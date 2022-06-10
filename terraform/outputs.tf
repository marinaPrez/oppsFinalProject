output "vpc_id" {
  value = module.networking.vpcid
}

output "servers_key" {
  value = module.ssh_keys.servers_key
}

##output "project_private_key" {
#  value = module.ssh_keys.project_private_key
#}



#output "my_ssh_key" {
#  value = module.consul.consul_ssh
#}

