# AWS VPC Peering with Terraform (LocalStack)

A comprehensive Terraform project demonstrating cross-region VPC peering between two AWS VPCs, designed to work with LocalStack for local development and testing before deploying to production AWS.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Components Deep Dive](#components-deep-dive)
- [Usage](#usage)
- [Outputs](#outputs)
- [Testing](#testing)
- [Traffic Flow Examples](#traffic-flow-examples)
- [LocalStack vs AWS](#localstack-vs-aws)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Cost Estimation](#cost-estimation)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project creates a complete multi-region VPC peering setup using Terraform and LocalStack. It demonstrates:

- ✅ Cross-region VPC peering between two VPCs (us-east-1 ↔ us-west-2)
- ✅ EC2 instances in separate regions communicating privately
- ✅ Security groups configured for inter-VPC communication
- ✅ Apache web servers for testing connectivity
- ✅ Internet Gateways for public access
- ✅ Complete routing configuration for both internet and peering traffic

**Environment:** Staging  
**Mode:** LocalStack (Local AWS Emulation) with AWS deployment option

## 🏗️ Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS Multi-Region Infrastructure                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────┐         ┌─────────────────────────────────────┐
│   Primary VPC (us-east-1)           │         │   Secondary VPC (us-west-2)         │
│   CIDR: 10.0.0.0/16                 │         │   CIDR: 10.1.0.0/16                 │
│   Environment: staging              │         │   Environment: staging              │
│                                     │         │                                     │
│  ┌──────────────────────────────┐   │         │  ┌──────────────────────────────┐   │
│  │  Primary Subnet              │   │         │  │  Secondary Subnet            │   │
│  │  CIDR: 10.0.0.0/16           │   │         │  │  CIDR: 10.1.0.0/16           │   │
│  │  AZ: us-east-1a              │   │         │  │  AZ: us-west-2a              │   │
│  │                              │   │         │  │                              │   │
│  │  ┌────────────────────────┐  │   │         │  │  ┌────────────────────────┐  │   │
│  │  │  EC2 Instance          │  │   │         │  │  │  EC2 Instance          │  │   │
│  │  │  Type: t2.micro        │  │   │         │  │  │  Type: t2.micro        │  │   │
│  │  │  Public: 54.214.160.87 │  │   │         │  │  │  Public: 54.214.176.184│  │   │
│  │  │  Private: 10.0.0.4     │◄─┼───┼─────────┼──┼─►│  Private: 10.1.0.4     │  │   │
│  │  │  Apache Web Server     │  │   │ Peering │  │  │  Apache Web Server     │  │   │
│  │  │  Key: vpc-peering-demo │  │   │         │  │  │  Key: vpc-peering-demo │  │   │
│  │  └────────────────────────┘  │   │         │  │  └────────────────────────┘  │   │
│  │             │                │   │         │  │             │                │   │
│  │  ┌──────────▼──────────────┐ │   │         │  │  ┌──────────▼──────────────┐ │   │
│  │  │  Security Group         │ │   │         │  │  │  Security Group         │ │   │
│  │  │  - SSH: 0.0.0.0/0       │ │   │         │  │  │  - SSH: 0.0.0.0/0       │ │   │
│  │  │  - ICMP: 10.1.0.0/16    │ │   │         │  │  │  - ICMP: 10.0.0.0/16    │ │   │
│  │  │  - TCP: 10.1.0.0/16     │ │   │         │  │  │  - TCP: 10.0.0.0/16     │ │   │
│  │  └─────────────────────────┘ │   │         │  │  └─────────────────────────┘ │   │
│  └──────────────────────────────┘   │         │  └──────────────────────────────┘   │
│            │                        │         │            │                        │
│  ┌──────────▼──────────────────┐    │         │  ┌──────────▼──────────────────┐    │
│  │  Route Table                │    │         │  │  Route Table                │    │
│  │  - 0.0.0.0/0 → IGW          │    │         │  │  - 0.0.0.0/0 → IGW          │    │
│  │  - 10.1.0.0/16 → Peering    │    │         │  │  - 10.0.0.0/16 → Peering    │    │
│  └─────────────────────────────┘    │         │  └─────────────────────────────┘    │
│            │                        │         │            │                        │
│  ┌──────────▼──────────────────┐    │         │  ┌──────────▼──────────────────┐    │
│  │  Internet Gateway           │    │         │  │  Internet Gateway           │    │
│  │  Public Access              │    │         │  │  Public Access              │    │
│  └─────────────────────────────┘    │         │  └─────────────────────────────┘    │
└─────────────────────────────────────┘         └─────────────────────────────────────┘
            │                                               │
            └───────────────────────┬───────────────────────┘
                                    │
                    Internet / LocalStack Endpoint
                      (http://localhost:4566)
```

## ✨ Features

- 🌐 **Multi-Region Deployment**: Resources across us-east-1 and us-west-2
- 🔗 **VPC Peering**: Private communication between VPCs
- 🖥️ **EC2 Instances**: t2.micro instances with Apache web servers
- 🔒 **Security Groups**: Configured for SSH and inter-VPC traffic
- 🌍 **Internet Gateways**: Public internet access for both VPCs
- 📊 **Route Tables**: Proper routing for internet and peering traffic
- 🏷️ **Tagging**: Comprehensive resource tagging for organization
- 🔑 **SSH Key Pairs**: Configurable key pair names
- 🧪 **LocalStack Support**: Test locally before AWS deployment
- 📝 **User Data Scripts**: Automated Apache installation and configuration

## ✅ Prerequisites

### Required Software

| Software                                                                  | Version           | Purpose                |
| ------------------------------------------------------------------------- | ----------------- | ---------------------- |
| [Terraform](https://www.terraform.io/downloads.html)                      | >= 1.0            | Infrastructure as Code |
| [Docker](https://www.docker.com/get-started)                              | Latest            | Run LocalStack         |
| [LocalStack](https://docs.localstack.cloud/getting-started/installation/) | >= 3.0            | AWS Emulation          |
| [AWS CLI](https://aws.amazon.com/cli/)                                    | Latest (Optional) | Testing resources      |

### LocalStack Setup

1. **Start LocalStack:**

```bash
   # Using Docker (Recommended)
   docker run -d \
     --name localstack \
     -p 4566:4566 \
     -p 4510-4559:4510-4559 \
     localstack/localstack
```

**Alternative - LocalStack CLI:**

```bash
   localstack start -d
```

2. **Verify LocalStack is running:**

```bash
   curl http://localhost:4566/_localstack/health
```

Expected response:

```json
{
  "services": {
    "ec2": "available",
    "s3": "available"
  }
}
```

## 📁 Project Structure

```
terraform-vpc-peering/
├── README.md                    # This comprehensive guide
├── main.tf                      # VPC, subnets, peering, EC2 resources
├── providers.tf                 # AWS provider (LocalStack configured)
├── variables.tf                 # Variable definitions with defaults
├── terraform.tfvars             # Your variable values ✓
├── outputs.tf                   # Output definitions
├── data.tf                      # Data sources (AMIs, AZs)
├── locals.tf                    # Local values (user_data scripts)
└── .gitignore                   # Git ignore patterns
```

## 🚀 Quick Start

### Step 1: Clone and Navigate

```bash
git clone <repository-url>
cd terraform-vpc-peering
```

### Step 2: Verify Prerequisites

```bash
# Check Terraform
terraform version

# Check Docker
docker --version

# Check LocalStack is running
docker ps | grep localstack
```

### Step 3: Configure Variables

Your `terraform.tfvars` is already set:

```hcl
environment        = "staging"
primary_key_name   = "vpc-peering-demo" # name of key pair for primary region
secondary_key_name = "vpc-peering-demo" # name of key pair for secondary region
```

### Step 4: Initialize Terraform

```bash
terraform init
```

Expected output:

```
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/aws v~> 6.0...

Terraform has been successfully initialized!
```

### Step 5: Review Plan

```bash
terraform plan
```

This shows all **18 resources** to be created:

- 2 VPCs
- 2 Subnets
- 2 Internet Gateways
- 2 Route Tables
- 2 Route Table Associations
- 2 Security Groups
- 2 EC2 Instances
- 1 VPC Peering Connection
- 1 VPC Peering Accepter
- 2 Peering Routes

### Step 6: Deploy Infrastructure

```bash
terraform apply --auto-approve
```

Wait approximately **30-60 seconds** for deployment.

### Step 7: View Outputs

```bash
terraform output
```

## ⚙️ Configuration

### Current Configuration (`terraform.tfvars`)

```hcl
environment        = "staging"
primary_key_name   = "vpc-peering-demo"
secondary_key_name = "vpc-peering-demo"
```

### Default Values (from `variables.tf`)

```hcl
localstack_endpoint  = "http://localhost:4566"
primary              = "us-east-1"
secondary            = "us-west-2"
primary_vpc_cidr     = "10.0.0.0/16"
secondary_vpc_cidr   = "10.1.0.0/16"
instance_type        = "t2.micro"
```

## 🔧 Components Deep Dive

### 1. VPCs (Virtual Private Clouds)

Creates two isolated networks in different AWS regions:

```hcl
resource "aws_vpc" "primary_vpc" {
  cidr_block           = var.primary_vpc_cidr  # 10.0.0.0/16
  provider             = aws.primary
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

**Purpose:**

- Isolated network environments in separate regions
- DNS support for internal hostname resolution
- Foundation for all other networking resources

**Key Features:**

- CIDR block defines IP address range
- DNS hostnames enabled for instance naming
- DNS support for internal resolution

---

### 2. Subnets

Creates one public subnet per VPC:

```hcl
resource "aws_subnet" "primary_subnet" {
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = var.primary_vpc_cidr
  availability_zone       = data.aws_availability_zones.primary_azs.names[0]
  map_public_ip_on_launch = true
}
```

**Key Features:**

- `map_public_ip_on_launch = true`: Auto-assigns public IPs
- Placed in first availability zone of each region
- Uses entire VPC CIDR range

---

### 3. Internet Gateways

Provides internet connectivity:

```hcl
resource "aws_internet_gateway" "primary_igw" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary
}
```

**Purpose:**

- Enables instances to communicate with the internet
- Required for SSH access from external networks
- Handles NAT for public IP addresses

---

### 4. Route Tables

Defines traffic routing rules:

```hcl
resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.primary_vpc.id
  provider = aws.primary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }
}
```

**Routes:**

- `0.0.0.0/0` → Internet Gateway: All internet traffic
- `10.1.0.0/16` → VPC Peering: Traffic to peered VPC (added separately)

**How it works:**

1. Check destination IP
2. If matches `0.0.0.0/0` → send to Internet Gateway
3. If matches `10.1.0.0/16` → send through VPC peering

---

### 5. VPC Peering Connection ⭐

The core component that connects the two VPCs:

#### Step 1: Peering Request (Primary → Secondary)

```hcl
resource "aws_vpc_peering_connection" "primary2_secondary_vpc_peering" {
  vpc_id      = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  peer_region = var.secondary
  auto_accept = false  # Cross-region requires manual acceptance
  provider    = aws.primary
}
```

#### Step 2: Accept Peering (Secondary)

```hcl
resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2_secondary_vpc_peering.id
  provider                  = aws.secondary
  auto_accept               = true
}
```

**How It Works:**

1. Primary VPC initiates peering request
2. Secondary VPC accepts the request
3. Private network link established between regions
4. Traffic flows over AWS backbone (never touches public internet)

---

### 6. Peering Routes

Adds routes to direct inter-VPC traffic through peering connection:

```hcl
# Primary → Secondary
resource "aws_route" "primary_to_secondary_route" {
  route_table_id            = aws_route_table.primary_route_table.id
  destination_cidr_block    = var.secondary_vpc_cidr  # 10.1.0.0/16
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2_secondary_vpc_peering.id
  provider                  = aws.primary
}

# Secondary → Primary
resource "aws_route" "secondary_to_primary_route" {
  route_table_id            = aws_route_table.secondary_route_table.id
  destination_cidr_block    = var.primary_vpc_cidr  # 10.0.0.0/16
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.secondary_accepter.id
  provider                  = aws.secondary
}
```

**Result:**

- Primary knows: "To reach 10.1.0.0/16, use peering connection"
- Secondary knows: "To reach 10.0.0.0/16, use peering connection"

---

### 7. Security Groups (Firewall Rules)

Controls inbound and outbound traffic:

```hcl
resource "aws_security_group" "primary_sg" {
  vpc_id = aws_vpc.primary_vpc.id

  # SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access from anywhere"
  }

  # ICMP (ping) from peered VPC
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
    description = "ICMP from secondary VPC"
  }

  # All TCP traffic from peered VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
    description = "All traffic from secondary VPC"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}
```

**Allowed Traffic:**

- ✅ SSH (port 22) from anywhere (0.0.0.0/0)
- ✅ All TCP traffic (ports 0-65535) from peered VPC CIDR
- ✅ ICMP (ping) from peered VPC
- ✅ All outbound traffic to anywhere

---

### 8. EC2 Instances

Compute instances in each VPC:

```hcl
resource "aws_instance" "primary_ec2" {
  ami                    = data.aws_ami.primary_ami.id
  instance_type          = var.instance_type        # t2.micro
  subnet_id              = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = var.primary_key_name     # vpc-peering-demo
  user_data              = local.primary_user_data
  provider               = aws.primary

  depends_on = [aws_vpc_peering_connection_accepter.secondary_accepter]

  tags = {
    Name        = "Primary-VPC-EC2-${var.primary}"
    environment = var.environment
    region      = var.primary
  }
}
```

**Features:**

- Runs Amazon Linux 2 AMI (latest)
- Instance type: t2.micro (free tier eligible)
- User data script installs and configures Apache
- Waits for peering to be established before launching

**User Data Script:**

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1> Primary VPC instance- us-east-1</h1>" > /var/www/html/index.html
echo "<p> Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
```

---

## 🎮 Usage

### Basic Commands

```bash
# Initialize project
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply --auto-approve

# Show current state
terraform show

# List all resources
terraform state list

# Destroy all resources
terraform destroy --auto-approve
```

### Advanced Commands

```bash
# View specific output
terraform output primary_vpc_id

# Output in JSON format
terraform output -json > outputs.json

# Refresh state
terraform refresh

# Target specific resource
terraform apply -target=aws_vpc.primary_vpc

# Import existing resource
terraform import aws_vpc.primary_vpc vpc-xxxxx

# Remove resource from state
terraform state rm aws_instance.primary_ec2
```

## 📤 Outputs

After successful deployment:

### Instance Information

```bash
primary_instance_id         = "i-a3c33e5c703ebb8ff"
primary_instance_private_ip = "10.0.0.4"
primary_instance_public_ip  = "54.214.160.87"

secondary_instance_id         = "i-0d4eae6ddd2e9b6bd"
secondary_instance_private_ip = "10.1.0.4"
secondary_instance_public_ip  = "54.214.176.184"
```

### Network Information

```bash
primary_vpc_id   = "vpc-79f9a711bfe328d55"
secondary_vpc_id = "vpc-f0d3f702ba5c1fe07"

primary_subnet_id   = "subnet-cddb6f3386674c111"
secondary_subnet_id = "subnet-2b3720bb73ac1cf52"

primary_security_group_id   = "sg-55687406a458d3426"
secondary_security_group_id = "sg-e1b55689853a4baae"
```

### VPC Peering Information

```bash
vpc_peering_connection_id = "pcx-9da71609d2cb09b00"
vpc_peering_status        = "active"
```

### Connection Commands

```bash
ssh_primary_command   = "ssh -i vpc-peering-demo.pem ec2-user@54.214.160.87"
ssh_secondary_command = "ssh -i vpc-peering-demo.pem ec2-user@54.214.176.184"

primary_web_url   = "http://54.214.160.87"
secondary_web_url = "http://54.214.176.184"
```

### Using Outputs in Scripts

```bash
# Get primary VPC ID
terraform output primary_vpc_id

# Get all outputs in JSON
terraform output -json > outputs.json

# Use in shell scripts
PRIMARY_IP=$(terraform output -raw primary_instance_public_ip)
curl http://$PRIMARY_IP
```

## 🧪 Testing

### Test 1: Verify Resource Creation

```bash
# Check VPCs
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs \
  --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

Expected output:

```
------------------------------------------------
|              DescribeVpcs                   |
+-------------------+-------------+------------+
|  vpc-79f9a711... |  10.0.0.0/16|  Primary-VPC-us-east-1  |
|  vpc-f0d3f702... |  10.1.0.0/16|  Secondary-VPC-us-west-2|
+-------------------+-------------+------------+
```

### Test 2: Check VPC Peering Status

```bash
# Check peering connection
aws --endpoint-url=http://localhost:4566 ec2 describe-vpc-peering-connections \
  --query 'VpcPeeringConnections[*].[VpcPeeringConnectionId,Status.Code]' \
  --output table
```

Expected: `active` status

### Test 3: Verify EC2 Instances

```bash
# List instances
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,PrivateIpAddress,State.Name]' \
  --output table
```

### Test 4: Check Security Groups

```bash
# Primary security group rules
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
  --group-ids $(terraform output -raw primary_security_group_id) \
  --query 'SecurityGroups[*].IpPermissions[*].[FromPort,ToPort,IpProtocol]' \
  --output table
```

### Test 5: Verify Route Tables

```bash
# Check routes
aws --endpoint-url=http://localhost:4566 ec2 describe-route-tables \
  --query 'RouteTables[*].Routes[*].[DestinationCidrBlock,GatewayId,VpcPeeringConnectionId]' \
  --output table
```

## 🔀 Traffic Flow Examples

### Internet Access (SSH from your computer)

```
Your Computer (Internet)
    │
    │ SSH (port 22)
    │ Public Network
    ▼
Public IP: 54.214.160.87
    │
    │ Internet Gateway
    ▼
Primary EC2 Instance
Private IP: 10.0.0.4
```

### Inter-VPC Communication (Private)

```
Primary EC2 (10.0.0.4)
    │
    │ 1. Check route table: 10.1.0.0/16 → VPC Peering
    │ 2. Security group: Allow from 10.1.0.0/16
    │ 3. Through VPC Peering Connection
    │ 4. AWS Private Network (never public internet)
    ▼
Secondary EC2 (10.1.0.4)
    │
    │ 5. Security group: Allow from 10.0.0.0/16
    │ 6. Destination reached
    ▼
Response back to Primary
```

### Web Server Access Between VPCs

```
Primary EC2                    Secondary EC2
(10.0.0.4)                     (10.1.0.4)
    │                              │
    │ HTTP Request                 │
    │ curl http://10.1.0.4         │
    │────────────────────────────► │
    │                              │ Apache responds
    │ HTTP Response                │ with HTML page
    │ ◄────────────────────────────│
    │                              │
```

### Complete Communication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Communication Flows                           │
└─────────────────────────────────────────────────────────────────┘

1. SSH Access (External → Instance)
   Internet → Public IP → Internet Gateway → Instance

2. Instance Internet Access (Instance → External)
   Instance → Internet Gateway → Public IP → Internet

3. Inter-VPC Ping (Instance ↔ Instance)
   Primary (10.0.0.4) ↔ VPC Peering ↔ Secondary (10.1.0.4)

4. HTTP Between Instances (Instance ↔ Instance)
   Primary:80 ↔ VPC Peering ↔ Secondary:80

5. SSH Between Instances (Instance → Instance)
   Primary:22 → VPC Peering → Secondary:22
```

## 🔄 LocalStack vs AWS

### Current Setup: LocalStack

| Aspect               | LocalStack Configuration |
| -------------------- | ------------------------ |
| **Credentials**      | Mock (`test` / `test`)   |
| **Endpoint**         | `http://localhost:4566`  |
| **Cost**             | Free                     |
| **SSH Access**       | ❌ Not available         |
| **Web Access**       | ❌ Not available         |
| **Resource APIs**    | ✅ Available             |
| **State Management** | ✅ Available             |
| **Network Traffic**  | ❌ Not available         |

### What Works in LocalStack

✅ **Works:**

- Terraform resource creation
- State management
- Resource queries via AWS CLI
- Output values
- VPC/Subnet/Security Group creation
- VPC Peering connections (API level)
- Testing Terraform configuration
- Resource tagging and metadata

❌ **Doesn't Work:**

- Actual EC2 instances (no VMs)
- SSH connectivity
- HTTP/web server access
- User data script execution
- Real network traffic
- Actual compute resources
- Cross-region latency simulation

### Switching to Real AWS

#### 1. Update `providers.tf`

Replace entire file with:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Default provider
provider "aws" {
  region = var.primary
}

# Primary provider
provider "aws" {
  region = var.primary
  alias  = "primary"
}

# Secondary provider
provider "aws" {
  region = var.secondary
  alias  = "secondary"
}
```

#### 2. Create SSH Key Pairs in AWS

```bash
# For Primary Region (us-east-1)
aws ec2 create-key-pair \
  --key-name vpc-peering-demo \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > vpc-peering-demo-east.pem

chmod 400 vpc-peering-demo-east.pem

# For Secondary Region (us-west-2)
aws ec2 create-key-pair \
  --key-name vpc-peering-demo \
  --region us-west-2 \
  --query 'KeyMaterial' \
  --output text > vpc-peering-demo-west.pem

chmod 400 vpc-peering-demo-west.pem
```

#### 3. Set AWS Credentials

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Or use AWS CLI
aws configure
```

#### 4. Deploy to AWS

```bash
# Re-initialize (removes LocalStack config)
terraform init -reconfigure

# Review plan and costs
terraform plan

# Deploy
terraform apply
```

#### 5. Test Real Infrastructure

```bash
# Wait for instances to initialize (2-3 minutes)
sleep 180

# Test primary web server
curl http://$(terraform output -raw primary_instance_public_ip)

# Expected output:
# <h1> Primary VPC instance- us-east-1</h1>
# <p> Private IP: 10.0.0.4</p>

# SSH to primary instance
ssh -i vpc-peering-demo-east.pem \
  ec2-user@$(terraform output -raw primary_instance_public_ip)

# From inside primary, test connectivity to secondary
ping $(terraform output -raw secondary_instance_private_ip)
curl http://$(terraform output -raw secondary_instance_private_ip)
ssh ec2-user@$(terraform output -raw secondary_instance_private_ip)
```

## 🐛 Troubleshooting

### LocalStack Issues

#### Problem: LocalStack not responding

```bash
# Check if running
docker ps | grep localstack

# Check logs
docker logs localstack --tail 50

# Restart LocalStack
docker restart localstack

# Stop and start fresh
docker stop localstack
docker rm localstack
docker run -d --name localstack -p 4566:4566 localstack/localstack
```

#### Problem: Port 4566 already in use

```bash
# Find what's using the port
lsof -i :4566

# Kill the process
kill -9 <PID>

# Or use different port
docker run -d -p 4567:4566 localstack/localstack

# Update terraform.tfvars
localstack_endpoint = "http://localhost:4567"
```

#### Problem: Health check fails

```bash
# Wait for LocalStack to fully start
sleep 15
curl http://localhost:4566/_localstack/health

# Check specific service
curl http://localhost:4566/_localstack/health | jq '.services.ec2'
```

### Terraform Issues

#### Problem: Provider initialization fails

```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Re-initialize
terraform init
```

#### Problem: State is locked

```bash
# View lock info
terraform force-unlock -force <LOCK_ID>

# Or remove state lock file (local state only)
rm -f .terraform.tfstate.lock.info
```

#### Problem: Resource already exists

```bash
# Import existing resource
terraform import aws_vpc.primary_vpc vpc-xxxxx

# Or remove from state
terraform state rm aws_vpc.primary_vpc

# Then recreate
terraform apply
```

#### Problem: Inconsistent state

```bash
# Refresh state to match reality
terraform refresh

# Or force replacement
terraform apply -replace=aws_instance.primary_ec2
```

### AWS Deployment Issues

#### Problem: Cannot SSH to instances (AWS)

**Possible Causes:**

- Security group blocking your IP
- Wrong .pem file or permissions
- Instance not fully initialized
- Network ACL blocking traffic

**Solutions:**

```bash
# Check security group allows your IP
YOUR_IP=$(curl -s ifconfig.me)
echo "Your IP: $YOUR_IP"

# Fix .pem permissions
chmod 400 vpc-peering-demo-east.pem

# Wait for instance initialization
sleep 180

# Check instance status
aws ec2 describe-instance-status --instance-ids <INSTANCE_ID>
```

#### Problem: Ping fails between instances

**Possible Causes:**

- VPC peering not active
- Routes not configured
- Security groups blocking ICMP

**Solutions:**

```bash
# Check peering status
aws ec2 describe-vpc-peering-connections \
  --vpc-peering-connection-ids $(terraform output -raw vpc_peering_connection_id)

# Verify routes exist
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$(terraform output -raw primary_vpc_id)"

# Check security group allows ICMP
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw primary_security_group_id)
```

#### Problem: HTTP not working between instances

**Possible Causes:**

- Apache not running
- Security groups blocking port 80
- User data script failed
- Instance not initialized

**Solutions:**

```bash
# SSH to instance
ssh -i vpc-peering-demo-east.pem ec2-user@<PUBLIC_IP>

# Check Apache status
sudo systemctl status httpd

# Check if Apache is listening
sudo netstat -tlnp | grep :80

# View user data logs
sudo cat /var/log/cloud-init-output.log

# Manually start Apache if needed
sudo systemctl start httpd
sudo systemctl enable httpd
```

### Common Errors and Solutions

#### Error: "InvalidKeyPair.NotFound"

```
Error: InvalidKeyPair.NotFound: The key pair 'vpc-peering-demo' does not exist
```

**Solution:**

```bash
# Create key pairs in both regions BEFORE terraform apply
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-east-1
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-west-2
```

#### Error: "No valid credential sources found"

**Solution for LocalStack:** Already configured with mock credentials.

**Solution for AWS:**

```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

# Or use AWS CLI configuration
aws configure
```

#### Error: "VPC peering connection not found"

**Solution:**

```bash
# Check if peering exists
aws --endpoint-url=http://localhost:4566 ec2 describe-vpc-peering-connections

# Destroy and recreate peering
terraform destroy -target=aws_vpc_peering_connection.primary2_secondary_vpc_peering
terraform destroy -target=aws_vpc_peering_connection_accepter.secondary_accepter
terraform apply
```

#### Error: "CIDR block conflict"

```
Error: CidrBlockConflict: CIDR block 10.0.0.0/16 conflicts with existing CIDR block
```

**Solution:**

```bash
# Use different CIDR blocks in terraform.tfvars
primary_vpc_cidr   = "172.16.0.0/16"
secondary_vpc_cidr = "172.17.0.0/16"
```

## 🧹 Cleanup

### Destroy All Resources

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy everything
terraform destroy --auto-approve
```

Expected output:

```
Destroy complete! Resources: 18 destroyed.
```

### Verify Cleanup

```bash
# Check no VPCs remain
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs

# Check Terraform state is empty
terraform show

# Should output: No state.
```

### Clean Terraform Files

```bash
# Remove Terraform cache and state files
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*
rm -f .terraform.tfstate.lock.info
```

### Stop LocalStack

```bash
# Stop container
docker stop localstack

# Remove container
docker rm localstack

# Or use LocalStack CLI
localstack stop
```

### Clean Up AWS Key Pairs (if created)

```bash
# Delete from AWS
aws ec2 delete-key-pair --key-name vpc-peering-demo --region us-east-1
aws ec2 delete-key-pair --key-name vpc-peering-demo --region us-west-2

# Delete local .pem files
rm -f vpc-peering-demo-*.pem
```
