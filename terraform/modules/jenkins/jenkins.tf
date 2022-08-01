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
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
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
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
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
  /* ami = "ami-0cb4e786f15603b0d" */
  ami = lookup(var.ami, var.region)
  count = 1
  instance_type = "t2.micro"
 # key_name = "${aws_key_pair.jenkins_ec2_key.key_name}"
  key_name = var.server_public_key
  subnet_id                = element(var.subnet_id, count.index)
  tags =        {
                  Name = "Jenkins Server"
                  role = "jenkins_master"
                  port = "8080"
                }
  associate_public_ip_address       = false
  vpc_security_group_ids = [aws_security_group.jenkins.id,  var.vpn_sg, var.consul_security_group]
  /* iam_instance_profile = [aws_iam_instance_profile.jenkins-role.name, var.consul_iam_instance_profile] */
  iam_instance_profile =  aws_iam_instance_profile.jenkins-role.name
  user_data = file("modules/jenkins/scripts/jenkins_server.tpl") 
}



resource "aws_instance" "jenkins_node" {
  #ami = "ami-0cb4e786f15603b0d"
  ami = lookup(var.ami, var.region)
  count = 1
  instance_type = "t2.micro"
  key_name = var.server_public_key
  subnet_id                = element(var.subnet_id, count.index)
  tags = {
         Name = "Jenkins Node"
         role = "jenkins_slave"
         port = "8080"
         }  
  associate_public_ip_address       = false
  vpc_security_group_ids = [aws_security_group.jenkins.id, var.vpn_sg, var.consul_security_group]
  user_data = file("modules/jenkins/scripts/jenkins-agent.tpl")
  iam_instance_profile =  aws_iam_instance_profile.jenkins-role.name
}
 
resource "aws_alb_target_group" "jenkins-server" {
  name     = "jenkins-server-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  /* health_check {
    path = "/"
    port = 9000
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  } */
}

resource "aws_alb_target_group_attachment" "jenkins-server" {
  count = 1
  target_group_arn = aws_alb_target_group.jenkins-server.arn
  target_id        = aws_instance.jenkins_server.*.id[count.index]
  port             = 8080
}

