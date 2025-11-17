# Task: Private EKS Setup

**Goal:** Learn about private cloud provisioning with Infrastructure as Code (IaC) and demonstrate the ability to work with private Kubernetes clusters in AWS.

## Overview

Create a Private EKS cluster in AWS using Terraform, and demonstrate that you can deploy the echo service application to it from your local machine using Helm.

## Requirements

### 1. AWS Account Setup
- Sign up for an AWS free tier account (or use an existing account)
- Configure AWS CLI with appropriate credentials
- Note: EKS will incur costs for the control plane plus EC2 instances

### 2. Infrastructure as Code with Terraform
Create Terraform files that allow you to spin up (or tear down) a Private EKS cluster, including:
- **VPC** with public and private subnets across multiple availability zones
- **Private EKS cluster** with private API endpoint
- **Node group** (worker nodes) in private subnets
- **NAT Gateway** for outbound internet access from private subnets
- **Security groups** and IAM roles as needed
- **Bastion host** or **VPN/VPC peering** for accessing the private cluster

**Configuration notes:**
- The EKS API endpoint must be private (not publicly accessible)
- Follow Terraform best practices:
  - Use variables for configurable values (region, cluster name, instance types, CIDR blocks, etc.)
  - Use outputs to expose important values (cluster endpoint, security group IDs, etc.)
  - Organize code into logical modules where appropriate
  - Use `terraform.tfvars` or similar for environment-specific values
- Use data sources to fetch dynamic values (availability zones, AMIs, etc.)

### 3. Verify Cloud Provider's Remote Command Feature
- Test whether the cloud provider's remote command execution feature works
- Send basic `kubectl` commands to the API server through the cloud provider's CLI or web console
- Understand the limitations of this approach for a private cluster

### 4. Implement Direct Connection Approach
Research and implement an alternative approach (not remote command execution) to directly connect to the private EKS cluster from your local machine, enabling:
- Running `kubectl` commands directly from your local machine
- Running `helm` commands directly from your local machine

**Possible approaches:**
- Cloud provider VPN service
- Bastion host with SSH tunneling
- VPC peering with local network
- Secure session management services for port forwarding

### 5. Deploy Echo Service with Helm
- Convert the existing echo service (currently in plain Kubernetes YAML) to a Helm chart following best practices
- Deploy the echo service to the private EKS cluster
- Verify that you can access the application (e.g., by port-forwarding to the echo service pod)
- Confirm the service responds correctly in your browser or via `curl`

## Deliverables

1. **Terraform code** - All IaC files needed to provision and destroy the infrastructure
2. **Helm chart** - Echo service packaged as a Helm chart

## Learning Objectives

- Understand private Kubernetes clusters and their security implications
- Gain hands-on experience with AWS EKS
- Practice Infrastructure as Code with Terraform following industry best practices
- Learn Helm chart development following the official best practices and conventions
- Apply the principle of parameterization and reusability in both Terraform and Helm
- Explore different approaches to accessing private cloud resources
- Understand proper configuration management and separation of concerns
