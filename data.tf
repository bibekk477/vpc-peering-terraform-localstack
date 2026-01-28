# data source for availability zone in the primary region
data "aws_availability_zones" "primary_azs" {
    provider = aws.primary
    state = "available"
} 
# data source for availability zone in the secondary region
data "aws_availability_zones" "secondary_azs" {
    provider = aws.secondary
    state = "available"
}

# data source for primary region AMI
data "aws_ami" "primary_ami" {
    provider = aws.primary
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}
# data source for secondary region AMI
data "aws_ami" "secondary_ami" {
    provider = aws.secondary
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}