
# Observing Amazon EKS Cluster with AWS services for OSS tooling

This part of this pattern creates the Amazon EKS Cluster and its minimal configuration to be able to run the simplest application on it. That means that the following resources and configurations are provisioned in this part:

* [Amazon Elastic Kubernetes Services( Amazon EKS )](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
* [Amazon EKS Addons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) for: 
  * [Amazon VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
  * [kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
  * [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
* [Amazon EKS Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - this is a static set of nodes (meaning they're not autoscale up or down) that are used by the core addons that runs on the cluster, mainly for Karpenter
* [Karpenter] addon (https://karpenter.sh) - for node autoscaling with a default provisioner for most use-cases

## Prerequisites  

None

## Using the services deployed in this part

### Amazon EKS 

To be able to interact with the cluster, the 4 users that are created in the previous part, are mapped to a 4 [user-facing roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) defined by the [cluster access management](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html) configuration. 

Therefore, to be able to access the cluster, a user has to be able to assume one of those 4 roles and update the cluster `~/.kube/config` file to use the specific role it can assume.

## Architecture Decisions  

### Provision Karpenter and a base set of addons as part of the cluster creation process

#### Context

Provisioning a cluster is not enough to run applications on it. Cluster data-plane, which is nodes provisioned by Amazon EKS Managed node groups w/Cluster-Autoscaler or Karpenter, as well as [Kubernetes addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/) required for networking and service-discovery capabilities are required to be configured as well. This can be deployed in a 2 or even 3 stage process, or all-in-one meaning cluster, its data-plane, and the relevant addons.

#### Decision

Although cluster creation process can run separately from the Kubernetes addons deployment process, this pattern is grouping together to a single deployment unit the cluster creation, the core-functionality addons for networking and service-discovery/connectivity, and the data-plane node autoscaler at the same process. The rationality behind this, is that with this kind of grouping, it's easier to customize a per-workload addons on a later stage, while standardizing on a minimal yet viable cluster configuration to run a simple/basic app.

#### Consequences

This decision result in a separate processes for managing addons for the cluster: the first process set of baseline addons are deployed and configured alongside the cluster creation process, while the second (created in a separate folder) deploy and configure the relevant addons for the specific configuration.

### Karpenter deployed on Amazon EKS managed node group

#### Context

Karpenter is a Kubernetes addon that provide just-in-time nodes for a Kubernetes cluster. However, Karpenter pods still needs Kubernetes nodes to be run on. Couple of options are to use AWS Fargate with Amazon EKS, or a "static" set of nodes for the Karpenter pods. 

#### Decision

Since AWS Fargate requires different configuration and deployment types for addons due to Fargate limitations (mainly due to the inability to run DaemonSets which affects the deployment types of addons, especially those that provide networking and observability capabilities), this pattern uses a Amazon EKS  Managed node group for Karpenter pods, while Karpenter will provide nodes for all other workloads.

#### Consequences

Using Amazon EKS Managed node groups for Karpenter deployment, simplify the deployment of other networking and observability addons, mainly because the ability to deploy DaemonSets on the managed node groups

## Deploy it

To deploy this folder resources to a specific resources, use the following commands

```
terraform init --backend-config=../../00.global/global-backend-config
terraform workspace new <YOUR_ENV>
terraform workspace select <YOUR_ENV>
terraform apply -var-file="../../00.global/vars/dev.tfvars"
```


## Troubleshooting



## Terraform docs
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.40.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.16.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 2.1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.22.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.40.0 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | >= 5.40.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 2.1.3 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.22.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_driver_irsa"></a> [ebs\_csi\_driver\_irsa](#module\_ebs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.43 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.24.0 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | ~> 1.16.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_tag.cluster_primary_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_eks_access_entry.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [kubectl_manifest.karpenter_manifests](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_annotations.gp2](https://registry.terraform.io/providers/hashicorp/kubernetes/2.22.0/docs/resources/annotations) | resource |
| [kubernetes_storage_class_v1.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/2.22.0/docs/resources/storage_class_v1) | resource |
| [null_resource.update-kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecrpublic_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubectl_path_documents.karpenter_manifests](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/data-sources/path_documents) | data source |
| [terraform_remote_state.iam](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | cluster configurations such as version, public/private API endpoint, and more | `map(string)` | `{}` | no |
| <a name="input_kms_key_admin_roles"></a> [kms\_key\_admin\_roles](#input\_kms\_key\_admin\_roles) | list of role ARNs to add to the KMS policy | `list(string)` | `[]` | no |
| <a name="input_shared_config"></a> [shared\_config](#input\_shared\_config) | Shared configuration across all modules/folders | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | n/a |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The EKS Cluster version |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_kubernetes_version"></a> [kubernetes\_version](#output\_kubernetes\_version) | The EKS Cluster version |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The OIDC Provider ARN |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->