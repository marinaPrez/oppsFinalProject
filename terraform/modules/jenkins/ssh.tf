##################################
# create ssh keys
#################################

resource "tls_private_key" "jenkins_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "jenkins_ec2_key" {
  key_name   = "jenkins_ec2_key"
  public_key = tls_private_key.jenkins_ec2_key.public_key_openssh
}

# Save generated key pair locally
  resource "local_file" "jenkins_server_key" {
  sensitive_content  = tls_private_key.jenkins_ec2_key.private_key_pem
  filename           = "jenkins_ec2_key.pem"
}
