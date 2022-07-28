



module "ssh_keys" {
  source   = "./modules/ssh_keys"
  key_pair = var.key_pair_names
}


module "vpn" {
  source    = "./modules/vpn"
  vpc_id = module.networking.vpcid
  subnet_id = module.networking.public-subnet-id
  server_public_key = module.ssh_keys.servers_key[2]
  servers_private_key = module.ssh_keys.servers_private_key[2]
  availability_zone = var.availability_zone[0]
}



module "consul" {
  source    = "./modules/consul"
  vpc_id = module.networking.vpcid
  vpn_sg = module.vpn.vpn_sg
  subnet_id = module.networking.private-subnet-id
  server_public_key = module.ssh_keys.servers_key[0]
  servers_private_key = module.ssh_keys.servers_private_key[0]
  availability_zone = var.availability_zone
  ami = var.ami
  region = var.region
}

module "networking" {
  source    = "./modules/network"
  consul_target_group_arn = module.consul.consul-server-target-group-arn
  jenkins_target_group_arn = module.jenkins.jenkins-server-target-group-arn
 } 


module "jenkins" {
  source    = "./modules/jenkins"
  vpc_id = module.networking.vpcid
  vpn_sg = module.vpn.vpn_sg
  server_public_key = module.ssh_keys.servers_key[1]
  servers_private_key = module.ssh_keys.servers_private_key[1]
  subnet_id = module.networking.private-subnet-id
  availability_zone = var.availability_zone
  ami = var.ami
  region = var.region
  consul_iam_instance_profile = module.consul.aws_iam_instance_profile
  consul_security_group = module.consul.consul_security_group_id
  consul_join_policy_arn= module.consul.consul_join_policy_arn
}


module "k8s" {
  source    = "./modules/k8s"
  vpc_id = module.networking.vpcid
  #vpn_sg = module.vpn.vpn_sg
  subnet_ids = module.networking.private-subnet-id
  role_arn  = module.jenkins.jenkins_role_arn
  role_name = module.jenkins.jenkins_role_name
  #server_public_key = module.ssh_keys.servers_key[0]
  #servers_private_key = module.ssh_keys.servers_private_key[0]
  #availability_zone = var.availability_zone
}

 module "elastic" {
  source    = "./modules/elastic"
  vpc_id = module.networking.vpcid
  subnet_id = module.networking.private-subnet-id
  server_public_key = module.ssh_keys.servers_key[4]
  servers_private_key = module.ssh_keys.servers_private_key[4]
  availability_zone = var.availability_zone[0] 
  ami = var.ami
  region = var.region
  consul_iam_instance_profile = module.consul.aws_iam_instance_profile
  consul_security_group = module.consul.consul_security_group_id
   }