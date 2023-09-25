resource "aws_eks_cluster" "sta_cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids =[ var.subnet_ids[0], module.vpc.subnet_ids[1]]
  }
}

resource "aws_eks_node_group" "worker-group" {
  count           = var.create_node_group ? var.number_of_nodegroups : 0
  cluster_name    = aws_eks_cluster.sta_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.worker-role.arn
  subnet_ids      = [module.vpc.subnet_ids[2], module.vpc.subnet_ids[3]]
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }
  ami_type       = var.ami_type
  capacity_type  = var.capacity_type
  instance_types = [var.instance_types]
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
