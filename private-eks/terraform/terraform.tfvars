aws_region     = "eu-central-1"
cluster_name   = "cute-kube-private-eks"
cluster_version = "1.33"

# Network configuration
vpc_cidr             = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# Node group configuration
node_instance_type = "t3.micro"
node_desired_size  = 1
node_min_size      = 1
node_max_size      = 2

# Bastion host configuration
enable_bastion        = true
bastion_instance_type = "t3.micro"

project_tags = {
  Project     = "cute-kube-lab"
  Environment = "testing"
  ManagedBy   = "terraform"
}
