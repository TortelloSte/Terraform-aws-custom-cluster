provider "aws" {
  region = var.region
}
 
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
 
locals {
  cluster_name = "cluster-name"
}
 
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
 
  name = "vpc-name"
 
  cidr = "10.1.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
 
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
 
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
 
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
 
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"
 
  cluster_name    = local.cluster_name
  cluster_version = "1.30"
 
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
 
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  enable_irsa = true
 
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
}
 
resource "aws_eks_node_group" "node_group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "node-group-name"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnets
 
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }
 
  instance_types = ["t3.nano"] # choose at this site: https://aws.amazon.com/it/ec2/instance-types/
  capacity_type  = "ON_DEMAND"
  disk_size      = 10
 
  tags = {
    Name = "node-group-tag-name"
  }
}
 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
 
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"
 
  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
 
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
 
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }
}
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}
 
data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}
 
data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

resource "aws_iam_role" "eks_node_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
}
 
data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
 
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
 
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}
 
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}
 
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# Add on: efs-csi and metrics into cluster

# AWS EFS CSI Driver installation by helm
resource "helm_release" "aws_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  create_namespace = true
}

# Metric Server Installation
resource "kubernetes_manifest" "metrics_server_base" {
  provider = kubernetes
  manifest = yamldecode(
    file("https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml")
  )
}

resource "kubernetes_manifest" "metrics_server_high_availability" {
  provider = kubernetes
  manifest = yamldecode(
    file("https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml")
  )
  
  depends_on = [kubernetes_manifest.metrics_server_base]
}

# installation of AWS load balancer controller and adding WAF from Terraform

# AWS Load Balancer Controller setup
resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  path   = "/"
  policy = file("iam_policy_latest.json")
}

resource "aws_iam_role" "load_balancer_controller_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_load_balancer_policy" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
  role       = aws_iam_role.load_balancer_controller_role.name
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "iam-test-001"
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [aws_iam_role_policy_attachment.attach_load_balancer_policy]
}

# AWS WAF for Load Balancer
resource "aws_wafv2_web_acl" "lb_waf" {
  name        = "lb-web-acl"
  description = "WAF for load balancer controller"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "block-bad-requests"
    priority = 1
    action {
      block {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blocked_requests"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf_metric"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "lb_waf_association" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.lb_waf.arn
}

# Load Balancer resource
resource "aws_lb" "alb" {
  name               = "eks-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.default_security_group_id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
  idle_timeout               = 400

  tags = {
    Name = "eks-alb"
  }
}