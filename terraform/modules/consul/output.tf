#output "consul_ssh"{
#    value = var.pem_key_name
#}

output "consul_servers" {
  value = ["${aws_instance.consul_server.*.private_ip}"]
}

#output "consul_agent" {
#  value = aws_instance.consul_agent.public_ip
#}

output "consul-server-target-group-arn" {
    value = aws_alb_target_group.consul_server.arn
}