# for primary vpc
resource "aws_vpc" "primary_vpc" {
  cidr_block       = var.primary_vpc_cidr
  provider = aws.primary
  enable_dns_hostnames=true 
  enable_dns_support=true
  instance_tenancy = "default"

  tags = {
    Name = "Primary-VPC-${var.primary}"
  }
}

# for secondary vpc
resource "aws_vpc" "secondary_vpc" {
  cidr_block       = var.secondary_vpc_cidr
  provider = aws.secondary
  enable_dns_hostnames=true 
  enable_dns_support=true
  instance_tenancy = "default"

  tags = {
    Name = "Secondary-VPC-${var.secondary}"
  }
}

# aws primary subnet
resource "aws_subnet" "primary_subnet" {
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block       = var.primary_vpc_cidr
  availability_zone = data.aws_availability_zones.primary_azs.names[0]
  provider = aws.primary
  map_public_ip_on_launch = true

  tags = {
    Name = "Primary-Subnet-${var.primary}"
    environment = var.environment
  }
}

# aws secondary subnet
resource "aws_subnet" "secondary_subnet" {
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block       = var.secondary_vpc_cidr
  availability_zone = data.aws_availability_zones.secondary_azs.names[0]
  provider = aws.secondary
  map_public_ip_on_launch = true
  tags = {
    Name = "Secondary-Subnet-${var.secondary}"
    environment = var.environment
  }
}

# internet gateway in primary vpc
resource "aws_internet_gateway" "primary_igw" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary

 tags = {
    Name = "Primary-IGW-${var.primary}"
    environment = var.environment
  }
}
# internet gateway in secondary vpc
resource "aws_internet_gateway" "secondary_igw" {
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  tags = {
      Name = "Secondary-IGW-${var.secondary}"
      environment = var.environment
    }

}
# route table for primary vpc
resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.primary_vpc.id
  provider = aws.primary
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }
  tags = {
    Name = "Primary-Route-Table-${var.primary}"
    environment = var.environment
  }
}

# route table for secondary vpc
resource "aws_route_table" "secondary_route_table" {
  vpc_id = aws_vpc.secondary_vpc.id
  provider = aws.secondary
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }
  tags = {
    Name = "Secondary-Route-Table-${var.secondary}"
    environment = var.environment
  }
}

# route table association for primary subnet
resource "aws_route_table_association" "primary_rta" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_route_table.id
  provider = aws.primary
}
# route table association for secondary subnet
resource "aws_route_table_association" "secondary_rta" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_route_table.id
  provider = aws.secondary
}

# VPC Peering Connection from Primary to Secondary VPC
resource "aws_vpc_peering_connection" "primary2_secondary_vpc_peering" {
  vpc_id        = aws_vpc.primary_vpc.id
  peer_vpc_id   = aws_vpc.secondary_vpc.id
  peer_region   = var.secondary
  provider = aws.primary
  auto_accept= false
  tags = {
    Name = "Primary-to-Secondary-VPC-Peering"
    environment = var.environment
  }
}
# VPC Peering Connection from Secondary to Primary VPC
resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2_secondary_vpc_peering.id
  provider = aws.secondary
  auto_accept=true
  depends_on = [aws_vpc_peering_connection.primary2_secondary_vpc_peering] 
  tags = {
    Name = "Secondary-to-Primary-VPC-Peering"
    environment = var.environment
  }
}

# aws route to primary vpc peering i.e Peering Routes
resource "aws_route" "primary_to_secondary_route" {
  route_table_id            = aws_route_table.primary_route_table.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2_secondary_vpc_peering.id
  provider = aws.primary

  depends_on = [aws_vpc_peering_connection.primary2_secondary_vpc_peering]

}

# aws route to secondary vpc peering i.e Peering Routes
resource "aws_route" "secondary_to_primary_route" {
  route_table_id            = aws_route_table.secondary_route_table.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.secondary_accepter.id
  provider = aws.secondary
  depends_on = [aws_vpc_peering_connection_accepter.secondary_accepter]
}

# security group for primary vpc ec2 instance
resource "aws_security_group" "primary_sg" {
  name        = "primary-sg-${var.primary}"
  description = "Security group for primary VPC EC2 instance"
  vpc_id      = aws_vpc.primary_vpc.id
  provider = aws.primary 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access from anywhere"
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr] 
    description = "ICMP from secondary VPC"
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr] 
    description = "All traffic from secondary VPC"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "Primary-VPC-SG-${var.primary}"
    environment = var.environment
  }

}
# security group for secondary vpc ec2 instance
resource "aws_security_group" "secondary_sg" {
  name        = "secondary-sg-${var.secondary}"
  description = "Security group for secondary VPC EC2 instance"
  vpc_id      = aws_vpc.secondary_vpc.id
  provider = aws.secondary 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access from anywhere"
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_vpc_cidr] 
    description = "ICMP from primary VPC"
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr] 
    description = "All traffic from primary VPC"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "Secondary-VPC-SG-${var.secondary}"
    environment = var.environment
  } 
}
# EC2 instance in primary VPC
resource "aws_instance" "primary_ec2" {
  ami           = data.aws_ami.primary_ami.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.primary_subnet.id
  vpc_security_group_ids  = [aws_security_group.primary_sg.id]
  provider = aws.primary 
  key_name = var.primary_key_name
  user_data = local.primary_user_data


  depends_on = [ aws_vpc_peering_connection_accepter.secondary_accepter ]
  tags = {
    Name = "Primary-VPC-EC2-${var.primary}"
    environment = var.environment
    region = var.primary
  }

}
# EC2 instance in secondary VPC
resource "aws_instance" "secondary_ec2" {
  ami           = data.aws_ami.secondary_ami.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.secondary_subnet.id  
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  provider = aws.secondary
  key_name = var.secondary_key_name
  user_data = local.secondary_user_data
  depends_on = [ aws_vpc_peering_connection_accepter.secondary_accepter ]
  tags = {
    Name = "Secondary-VPC-EC2-${var.secondary}"
    environment = var.environment
    region = var.secondary
  }
}