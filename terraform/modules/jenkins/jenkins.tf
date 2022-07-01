locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}


resource "aws_security_group" "jenkins" {
  name = local.jenkins_default_name
  vpc_id      = var.vpc_id
  description = "Allow Jenkins inbound traffic"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port = 0
    to_port = 0
    // -1 means all
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = local.jenkins_default_name
  }
}



###########################################
# Create Jenkins server 
##########################################
resource "aws_instance" "jenkins_server" {
  ami = "ami-0cb4e786f15603b0d"
  count = 1
  instance_type = "t2.micro"
 # key_name = "${aws_key_pair.jenkins_ec2_key.key_name}"
  key_name = var.server_public_key
  subnet_id                = element(var.subnet_id, count.index)
  tags =        {
                  Name = "Jenkins Server"
                  role = "Jenkins Master"
                  port = "8080"
                }
  associate_public_ip_address       = false
  vpc_security_group_ids = [aws_security_group.jenkins.id,  var.vpn_sg]
  user_data = file("modules/jenkins/scripts/jenkins_server.tpl") 



  /* provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io  -y",
      "sudo systemctl start docker",
      "sudo apt install openjdk-11-jre-headless -y",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}",
      "chmod +x /home/ubuntu/consul-agent.sh",
      "sudo /home/ubuntu/consul-agent.sh"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  } */

}


resource "aws_instance" "jenkins_node" {
  ami = "ami-0cb4e786f15603b0d"
  count = 1
  instance_type = "t2.micro"
  key_name = var.server_public_key
  subnet_id                = element(var.subnet_id, count.index)
  tags = {
         Name = "Jenkins Node"
         role = "Jemkins Slave"
         port = "8080"
         }  
  associate_public_ip_address       = false
  vpc_security_group_ids = [aws_security_group.jenkins.id, var.vpn_sg]
  user_data = file("modules/jenkins/scripts/jenkins-agent.tpl")
  iam_instance_profile = aws_iam_instance_profile.jenkins-role.name

  /* provisioner "file" {
    source      = "consul/scripts/consul-agent.sh"
    destination = "/home/ubuntu/consul-agent.sh"
    connection {
      host        = aws_instance.jenkins_node.private_ip
      user        = "ubuntu"
      private_key = var.private_key_name
    }
  } */


 /* connection {
    host = aws_instance.jenkins_node.private_ip
    user = "ubuntu"
    private_key = var.private_key_name
  } */

  /* provisioner "remote-exec" {

    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io git -y",
      "sudo systemctl start docker",
      "sudo apt install openjdk-11-jre-headless -y",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}",
      "chmod +x /home/ubuntu/consul-agent.sh",
      "sudo /home/ubuntu/consul-agent.sh"
    ]
  } */
}



