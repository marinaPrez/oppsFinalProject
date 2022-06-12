output "vpc_id" {
  value = module.networking.vpcid
}


output "vpn_server" {
  value = module.vpn.vpn_server_host_id
}


output "servers_key" {
  value = module.ssh_keys.servers_key
}


output "Jenkins_server" {
  value = module.jenkins.Jenkins_server
}

output "jenkins_agent" {
  value = module.jenkins.jenkins_agent
}
