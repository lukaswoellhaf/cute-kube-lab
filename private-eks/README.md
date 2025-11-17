# Private EKS Cluster Setup

Learning project: Deploy a private Amazon EKS cluster with Terraform and manage applications with Helm.

## 💰 Cost

**Important** Always run `terraform destroy` when done!

## 🔑 Key Concepts Learned

### NAT Gateway vs Bastion Host
- **NAT Gateway**: One-way router (private → internet) for downloading packages/images
- **Bastion Host**: SSH jump server to access private resources from your local machine

### EC2 vs EKS
- **EC2**: Virtual machines you fully manage
- **EKS**: Managed Kubernetes - AWS runs the control plane, you manage worker nodes
- EKS worker nodes ARE EC2 instances running containers

### CIDR Notation
- `/24` = 256 IPs, `/16` = 65,536 IPs
- Smaller number = MORE addresses
- `10.0.1.0/24` = IPs from `10.0.1.0` to `10.0.1.255`

## 🚀 Quick Start

### 1. Prerequisites
- AWS account with CLI configured (`aws configure`)
- Terraform, kubectl, Helm installed locally

### 2. Create SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cute-kube-bastion -N ""
```

### 3. Deploy Infrastructure
```bash
cd terraform/
terraform init
terraform apply
```

### 4. Connect to Bastion
```bash
ssh -i ~/.ssh/cute-kube-bastion ec2-user@<bastion-ip>
```

### 5. Configure kubectl (on bastion)
```bash
aws eks update-kubeconfig --region eu-central-1 --name cute-kube-private-eks
kubectl get nodes  # Verify cluster access
```

### 6. Deploy Echo Service (on bastion)
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Transfer chart from local machine
scp -r -i ~/.ssh/cute-kube-bastion echo-service ec2-user@<bastion-ip>:~/

# Deploy
helm install echo-service ./echo-service

# Fix pod limits if needed
kubectl scale deployment coredns --replicas=1 -n kube-system

# Test
kubectl port-forward svc/echo-service-echo-service 8080:80
curl http://localhost:8080
```

### 7. Clean Up
```bash
terraform destroy
```

## 📚 What We Built

**Infrastructure (Terraform):**
- VPC with private/public subnets across 3 availability zones
- Private EKS cluster (API not publicly accessible)
- NAT Gateway for outbound internet access
- Bastion host for cluster access
- Worker node in private subnet

**Application (Helm):**
- Custom Helm chart for echo-server application
- Parameterized values (image, replicas, resources)
- Template helpers for consistent naming/labeling
- Post-install notes for user guidance

## ❓ Key Questions & Answers

**Why can't I access the private EKS cluster from my local machine?**
- Private cluster API is only accessible within the VPC
- Must use bastion host as jump server

**Why do I need both NAT Gateway and Bastion?**
- NAT: Worker nodes pull images/updates (outbound only)
- Bastion: You SSH in to manage the cluster (bidirectional)

**Why did my pod fail with "Too many pods"?**
- t3.micro supports max 4 pods due to ENI/IP limits
- Solution: Scale CoreDNS to 1 replica

**What's the difference between chart version and appVersion?**
- Chart version: Version of the Helm packaging/templates
- appVersion: Version of the application being deployed

**Why use data sources instead of hardcoding AMI IDs?**
- AMI IDs change by region and with updates
- Data sources auto-fetch the latest valid AMI
