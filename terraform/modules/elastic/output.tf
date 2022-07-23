output "elastic_server_host_id" {
  value = aws_instance.elastic.*.private_ip
}

output "kibana_url" {
  value = "http://${aws_instance.elastic.*.private_ip[0]}:5601"
}