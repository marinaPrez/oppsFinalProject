output "elastic_server_host_id" {
  value = aws_instance.elastic.*.private_ip
}

output "kibana_url" {
  value = "http://${aws_instance.elastic.*.private_ip[0]}:5601"
}

output "elastic_target_group_arn" {
    value = aws_alb_target_group.elastic-server.arn
}