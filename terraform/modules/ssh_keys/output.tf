output "servers_key" {
  value = aws_key_pair.server_key.*.id
}

output "servers_public_key" {
  value = aws_key_pair.server_key.*.public_key
}

output "servers_private_key" {
  value = tls_private_key.server_key.*.private_key_pem
  sensitive   = true
}
