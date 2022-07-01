module "networking" {
  source    = "./modules/network"
}


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
}


module "jenkins" {
  source    = "./modules/jenkins"
  vpc_id = module.networking.vpcid
  vpn_sg = module.vpn.vpn_sg
  server_public_key = module.ssh_keys.servers_key[1]
  servers_private_key = module.ssh_keys.servers_private_key[1]
  subnet_id = module.networking.private-subnet-id
  availability_zone = var.availability_zone
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

