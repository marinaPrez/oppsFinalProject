output "Jenkins_server" {
  value = aws_instance.jenkins_server.*.private_ip
}

output "jenkins_agent" {
  value = aws_instance.jenkins_node.*.private_ip
}

output "jenkins_role_arn" {
  value = aws_iam_role.jenkins-role.arn
}

output "jenkins_role_name" {
  value = aws_iam_role.jenkins-role.name
}