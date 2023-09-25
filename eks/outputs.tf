/* output "cluster_id" {
  description = "EKS cluster ID."
  value       = aws_eks_cluster.sta_cluster.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = aws_eks_cluster.sta_cluster.endpoint
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.sta_cluster.name
}
output "identity" {
  value = aws_eks_cluster.sta_cluster.identity[0].oidc[0].issuer
}

output "oidc_id" {
  value = aws_iam_openid_connect_provider.default.id
  
}*/

output "identity" {
  value = aws_eks_cluster.sta_cluster.identity[0].oidc[0].issuer
}

output "oidc_id" {
  value = aws_iam_openid_connect_provider.default.id
}