# Dev environment variables 
vpc_cidr = "10.1.0.0/16"

# custom tags to apply to all resources
tags = {
}

shared_config = {
  resources_prefix = "wre" // WRE = Workload Ready EKS 
}

cluster_config = {
  kubernetes_version   = "1.29"
  private_eks_cluster  = false
  create_iam_role      = false
  private_eks_cluster  = false
  cluster_iam_role_arn = "{{CLUSTER_IAM_ROLE_ARN}}"
  use_intra_subnets    = false
  create_mng_system    = true
  capabilities = {
    networking    = true
    coredns       = true
    identity      = true
    autoscaling   = false
    blockstorage  = true
    loadbalancing = true
    gitops        = false
  }
}

# Observability variables 
observability_configuration = {
  aws_oss_tooling    = false
  aws_native_tooling = true
  aws_oss_tooling_config = {
    enable_managed_collector = false
    enable_adot_collector    = false
    prometheus_name          = "prom"
    enable_grafana_operator  = false

  }
}
