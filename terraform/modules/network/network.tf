data "aws_availability_zones" "available" {}


###########################
#create vpc
##########################

resource "aws_vpc" "oppschool_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Main VPC"
  }
}

#######################################
#public subnets
#####################################

resource "aws_subnet" "public" {
  count      = 2
  vpc_id     = aws_vpc.oppschool_vpc.id
  cidr_block = var.public_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet_${count.index}"
  }
}

####################################
#private subnets
###################################

resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = aws_vpc.oppschool_vpc.id
  cidr_block = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Private Subnet_${count.index}"
  }
}

###################
#internet gateway
###################

resource "aws_internet_gateway" "ing" {
   vpc_id     = aws_vpc.oppschool_vpc.id
   tags = {
    Name = "Public Subnet"
  }
}

##########################
#Elastic IP for NAT Gateway
##########################
resource "aws_eip" "nat_eip" {
   vpc = true
   count = 2
   depends_on = [aws_internet_gateway.ing]
   tags = {
    Name = "NAT gateway EIP"
    }
}

###################################
#create NAT gateway
###################################

resource "aws_nat_gateway" "nat_gw" {
  count = 2
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
  tags = {
    Name = "gw_NAT_${count.index}"
  }
  depends_on = [aws_internet_gateway.ing]
}

#####################################
#create routing attributes
#####################################

resource "aws_route_table" "public" {
#  count = 1
  vpc_id = aws_vpc.oppschool_vpc.id
  route {
     cidr_block = "0.0.0.0/0" 
     gateway_id = aws_internet_gateway.ing.id
     }
  tags = {
    "Name" = "Public route table"
  }
}
resource "aws_route_table_association" "public" {
  count = 2
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  count = 2
  vpc_id = aws_vpc.oppschool_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat_gw.*.id[count.index]
     }
  tags = {
    "Name" = "private route table"
  }
}
resource "aws_route_table_association" "private" {
  count = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}



##################################
# create ssh keys
#################################

/* resource "tls_private_key" "oppschool_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "oppschool_key" {
  key_name   = "oppschool_key"
  public_key = tls_private_key.oppschool_key.public_key_openssh
}
# Save generated key pair locally
  resource "local_file" "server_key" {
  sensitive_content  = tls_private_key.oppschool_key.private_key_pem
  filename           = "oppschool_key.pem"
} */

#######################################
#create instance profile
#####################################

resource "aws_iam_instance_profile" "web_profile" {
  name = "web_profile"
  role = "opsScool_role"
}

#####################################
## Application Load Balancer - alb ##
#####################################

resource "aws_alb" "alb1" {
  name = "alb1"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb1_sg.id]
  subnets = [for subnet in aws_subnet.public.*.id : subnet]
  tags = {
    Name = "application load balancer"
  }
}
 
/* resource "aws_alb_listener" "consul" {
  depends_on = [time_sleep.wait_for_certificate_verification] 
  load_balancer_arn = aws_alb.alb1.arn
  certificate_arn = aws_acm_certificate.cert.arn
  port              = "8500"
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = var.consul_target_group_arn
  }
}  */

###########################
 ## APB security group
###########################

resource "aws_security_group" "alb1_sg" {
  name ="alb1-security-group"
  vpc_id = aws_vpc.oppschool_vpc.id
  ingress {
    from_port = 8500
    to_port =  8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access"
  }
  ingress {
    from_port = 443
    to_port =  443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow jenkins UI secure access"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "app balancer security group"
  }
}

resource "aws_route53_record" "jenkins_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "jenkins"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}

resource "aws_route53_record" "consul_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "consul"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}  

 ## Create Certificate 
resource "aws_acm_certificate" "cert" {
  domain_name       = "ops-marina.online"
  #subject_alternative_names = ["*.ops-domain"]
  validation_method = "DNS"
  tags = {
    Name = "certificate-opps"
  }
}

/* resource "aws_route53_zone" "primary_domain" {
  name = "ops-marina.online"
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name = "hostedzone-ops"
  }
} */

data "aws_route53_zone" "primary_domain" {
  name         = "ops-marina.online"
  private_zone = false
}

resource "aws_route53_record" "ops_site" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary_domain.zone_id
}


resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.ops_site : record.fqdn]
  timeouts {
    create = "60m"
  }
} 

/* resource "time_sleep" "wait_for_certificate_verification" {
  depends_on = [aws_acm_certificate_validation.cert]
  create_duration = "60s"
}  */