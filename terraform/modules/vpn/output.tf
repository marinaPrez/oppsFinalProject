/* output "vpn_server_host_id" {
  value = aws_instance.vpn.*.id
} */

output "vpn_server_host_id" {
  value = aws_instance.vpn.public_ip
}

output "vpn_sg" {
  value = aws_security_group.vpn_sg.id
}

output "access_vpn_url" {
  value       = "https://${aws_instance.vpn.public_ip}:943/admin"
  description = "The public url address of the vpn server"
}