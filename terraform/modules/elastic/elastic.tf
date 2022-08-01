##################
#Create elastic server
##################

resource "aws_instance" "elastic" {
   ami                  = lookup(var.ami, var.region)
  count                 = 1
  instance_type         = "t3.medium"
  key_name              = var.server_public_key
  subnet_id             = element(var.subnet_id, count.index)
  vpc_security_group_ids            = [aws_security_group.elastic_sg.id,var.consul_security_group]
  iam_instance_profile              =  var.consul_iam_instance_profile
  user_data = file("./modules/elastic/userdata.sh")
  tags = {
    Name = "Elastic Search Server"
    role = "elastic_search"
    port = "5601"
  }
}

#####################################
#Create security group for elastic server
#####################################

resource "aws_security_group" "elastic_sg" {
  name        = "elastic_sg"
  description = "Allow straffic to elastic stack "
   vpc_id = var.vpc_id
  
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    description = "elasticsearch-rest-tcp"
    /* self        = true */
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh"
  }

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "elasticsearch-java-tcp"
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "elasticsearch-rest-tcp"
  }

   ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
  }
    ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "kibana web interface"
  }

    
    ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "logstash-tcp"
  }

  

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all for outside traffic"
  }
  tags = {
    "name" = "elastic_sg"
  }
}


