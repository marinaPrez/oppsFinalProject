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

  tags = {
    Name = "Consul-Server_${count.index}"
    consul_server = "true"
    role = "consul_server_${count.index}"
    environment = "production"
  }

}

#  create one consul agent
############################

resource "aws_instance" "consul_agent" {
  ami                               = lookup(var.ami, var.region)
  count                               = 1
  instance_type                     = "t2.micro"
  key_name                          = var.server_public_key
  subnet_id                         = element(var.subnet_id, count.index)
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids            = [aws_security_group.opsschool_consul.id, var.vpn_sg]
  user_data = file("modules/consul/scripts/consul-agent.tpl")
  
  tags = {
    Name = "Consul-agent"
    role = "ngnx"
    environment = "production"
    port = "80"
  }


}


resource "aws_alb_target_group" "consul_server" {
  name     = "consul-server-target-group"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  /* health_check {
    path = "/ui/ops-project/services"
    port = 8500
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  } */
}

resource "aws_alb_target_group_attachment" "consul_server" {
  count = 3
  target_group_arn = aws_alb_target_group.consul_server.arn
  target_id        = aws_instance.consul_server.*.id[count.index]
  port             = 8500
}