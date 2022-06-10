module "networking" {
  source    = "./modules/network"
}


module "ssh_keys" {
  source   = "./modules/ssh_keys"
  key_pair = var.key_pair_names
}


module "consul" {
  source    = "./modules/consul"
  vpc_id = module.networking.vpcid
  subnet_id = module.networking.private-subnet-id
  server_public_key = module.ssh_keys.servers_key[0]
  servers_private_key = module.ssh_keys.servers_private_key[0]
  availability_zone = var.availability_zone
}


#module "jenkins" {
#  source    = "./modules/jenkins"
#  vpc_id = module.networking.vpcid
#  public_key_name = var.jenkins_key_pair
#  private_key_name = var.jenkins_private_key
#  subnet_id = module.networking.private-subnet-id[0]
#}
