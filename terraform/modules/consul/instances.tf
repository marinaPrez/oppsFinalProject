# create 3 consul servers :
###########################

resource "aws_instance" "consul_server" {
  count         		        = 3
  ami           		       	= lookup(var.ami, var.region)
  instance_type                         = "t2.micro"
  availability_zone                     = element(var.availability_zone, count.index)
  key_name                              = var.server_public_key
  #subnet_id                            = aws_subnet.public.id
  subnet_id                             = element(var.subnet_id, count.index)
  iam_instance_profile                  = aws_iam_instance_profile.consul-join.name
  #associate_public_ip_address           = false
  vpc_security_group_ids 		= [aws_security_group.opsschool_consul.id, var.vpn_sg]
  user_data = file("modules/consul/scripts/consul-server.tpl")

#  provisioner "file" {
#    source      = "scripts/consul-server.sh"
#    destination = "/home/ubuntu/consul-server.sh"
#    connection {   
#      host        = self.public_ip
#      user        = "ubuntu"
#      #private_key = "opsschool_consul.pem"
#     # private_key = file("/Users/marinapr/opsScool/finalProject/terraform/oppschool_key.pem")       
#      private_key = var.servers_private_key
#     }   
#  }


#   provisioner "remote-exec" {
#    inline = [
#      "chmod +x /home/ubuntu/consul-server.sh",
#      "sudo /home/ubuntu/consul-server.sh",
#        ]
#    connection {
#      host        = self.public_ip
#      user        = "ubuntu"
#      private_key = var.servers_private_key
#   }
#  }


  tags = {
    Name = "opsschool-server_${count.index}"
    consul_server = "true"
    role = "consul server"
    environment = "production"
  }

}


#  create one consul agent
############################

resource "aws_instance" "consul_agent" {
  ami                               = lookup(var.ami, var.region)
  count                               = 1
  instance_type                     = "t2.micro"
  #key_name                         = aws_key_pair.opsschool_consul_key.key_name
  key_name                          = var.server_public_key
  #subnet_id                        = aws_subnet.public.id
  subnet_id                         = element(var.subnet_id, count.index)
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids            = [aws_security_group.opsschool_consul.id, var.vpn_sg]
  user_data = file("modules/consul/scripts/consul-agent.tpl")
  


#user_data       = <<EOF
#!bin/bash
#sudo apt-get update
#sudo apt-get install nginx -y
#echo "OPSSCHOOL RULES ! " | sudo tee /usr/share/nginx/html/index.html
#sudo systemctl start nginx
#EOF
 
#  provisioner "file" {
#    source      = "scripts/consul-agent.sh"
#    destination = "/home/ubuntu/consul-agent.sh"
#    connection {   
#      host        = self.public_ip
#      user        = "ubuntu"
#      private_key = var.servers_private_key
#    }   
#  }


#   provisioner "remote-exec" {
#    inline = [
#      "chmod +x /home/ubuntu/consul-agent.sh",
#      "sudo /home/ubuntu/consul-agent.sh &>> mylog.txt",
#         ]
#    connection {
#      host        = self.public_ip
#      user        = "ubuntu"
#      private_key = var.servers_private_key
#    }
#  }


  tags = {
    Name = "opsschool-agent"
    role = "ngnx"
    environment = "production"
    port = "80"
  }


}


