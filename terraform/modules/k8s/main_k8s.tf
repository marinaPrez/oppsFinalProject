resource "kubernetes_service_account" "opsschool_sa" {
  depends_on = [module.eks]
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn
    }
  }
}
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "eks-worker-management"
  vpc_id      =var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 8301
    to_port   = 8301
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
   egress {
    from_port = 8600
    to_port   = 8600
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 8302
    to_port   = 8302
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

   egress {
    from_port = 8300
    to_port   = 8300
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
  } 

   ingress {
    from_port   = 9153
    to_port     = 9153
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 

   ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 
  
     ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 

     ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }

  tags = {
    Name = "eks-sg-${var.project_name}"
    env = var.tag_enviroment
  }
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.6.1"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids         = var.subnet_ids

  enable_irsa = true
  
  tags = {
    Name = "eks-cluster-${var.project_name}"
    env = var.tag_enviroment
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
  vpc_id = var.vpc_id
  
  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    
    eks_group_1 = {
      min_size     = 1
      max_size     = 6
      desired_size = 1
      instance_types = ["t3.medium"]
    }

    eks_group_2 = {
      min_size     = 1
      max_size     = 6
      desired_size = 1
      instance_types = ["t3.medium"]

    }

    eks_group_2 = {
      min_size     = 1
      max_size     = 6
      desired_size = 1
      instance_types = ["t3.medium"]

    }

  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.7.0"
  create_role                   = true
  role_name                     = "opsschool-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# add Jenkins IAM role to EKS cluster

locals {
map_roles = [
    {
      rolearn  = var.role_arn
      username = var.role_name
      groups   = ["system:masters"]
    },
  ]
}

module "eks_auth" {
  source                   = "aidanmelen/eks-auth/aws"
  version                  = "1.0.0"
  eks                      = module.eks
  wait_for_cluster_timeout = 300
  map_roles                = local.map_roles

  depends_on = [module.eks]
}