#output "consul_ssh"{
#    value = var.pem_key_name
#}

#output "consul_servers" {
#  value = ["${aws_instance.consul_server.*.public_ip}"]
#}

#output "consul_agent" {
#  value = aws_instance.consul_agent.public_ip
#}
