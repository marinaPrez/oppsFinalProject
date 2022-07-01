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

output "jenkins_role_arn" {
  value = module.jenkins.jenkins_role_arn
  }


output "jenkins_role_name" {
  value = module.jenkins.jenkins_role_name
  }

output "k8s_cluster_id" {
  description = "EKS cluster ID."
  value       = module.k8s.cluster_id
}

output "k8s_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.k8s.cluster_endpoint
}

output "k8s_oidc_provider_arn" {
  value = module.k8s.oidc_provider_arn
}


