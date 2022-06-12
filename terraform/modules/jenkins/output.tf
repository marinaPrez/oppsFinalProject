output "Jenkins_server" {
  value = aws_instance.jenkins_server.*.private_ip
}

output "jenkins_agent" {
  value = aws_instance.jenkins_node.*.private_ip
}