# Output the Primary Instance Information
output "primary_instance_id" {
  description = "Primary EC2 instance ID"
  value       = aws_instance.primary_ec2.id
}

output "primary_instance_public_ip" {
  description = "Primary EC2 instance public IP address"
  value       = aws_instance.primary_ec2.public_ip
}

output "primary_instance_private_ip" {
  description = "Primary EC2 instance private IP address"
  value       = aws_instance.primary_ec2.private_ip
}

# Output the Secondary Instance Information
output "secondary_instance_id" {
  description = "Secondary EC2 instance ID"
  value       = aws_instance.secondary_ec2.id
}

output "secondary_instance_public_ip" {
  description = "Secondary EC2 instance public IP address"
  value       = aws_instance.secondary_ec2.public_ip
}

output "secondary_instance_private_ip" {
  description = "Secondary EC2 instance private IP address"
  value       = aws_instance.secondary_ec2.private_ip
}

# Output VPC Information
output "primary_vpc_id" {
  description = "Primary VPC ID"
  value       = aws_vpc.primary_vpc.id
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID"
  value       = aws_vpc.secondary_vpc.id
}

# Output VPC Peering Information
output "vpc_peering_connection_id" {
  description = "VPC Peering Connection ID"
  value       = aws_vpc_peering_connection.primary2_secondary_vpc_peering.id
}

output "vpc_peering_status" {
  description = "VPC Peering Connection Status"
  value       = aws_vpc_peering_connection.primary2_secondary_vpc_peering.accept_status
}

# Output Security Group Information
output "primary_security_group_id" {
  description = "Primary VPC Security Group ID"
  value       = aws_security_group.primary_sg.id
}

output "secondary_security_group_id" {
  description = "Secondary VPC Security Group ID"
  value       = aws_security_group.secondary_sg.id
}

# Output Subnet Information
output "primary_subnet_id" {
  description = "Primary Subnet ID"
  value       = aws_subnet.primary_subnet.id
}

output "secondary_subnet_id" {
  description = "Secondary Subnet ID"
  value       = aws_subnet.secondary_subnet.id
}

# SSH Connection Information
output "ssh_primary_command" {
  description = "SSH command to connect to primary instance"
  value       = "ssh -i vpc-peering-demo-east.pem ec2-user@${aws_instance.primary_ec2.public_ip}"
}

output "ssh_secondary_command" {
  description = "SSH command to connect to secondary instance"
  value       = "ssh -i vpc-peering-demo-west.pem ec2-user@${aws_instance.secondary_ec2.public_ip}"
}

# Web Server URLs
output "primary_web_url" {
  description = "Primary instance web server URL"
  value       = "http://${aws_instance.primary_ec2.public_ip}"
}

output "secondary_web_url" {
  description = "Secondary instance web server URL"
  value       = "http://${aws_instance.secondary_ec2.public_ip}"
}
