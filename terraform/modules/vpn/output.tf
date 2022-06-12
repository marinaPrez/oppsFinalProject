output "vpn_server_host_id" {
  value = aws_instance.vpn.*.id
}

output "vpn_sg" {
  value = aws_security_group.vpn_sg.id
}