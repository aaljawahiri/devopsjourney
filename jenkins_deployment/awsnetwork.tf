# Create VPN in eu-west-2
resource "aws_vpc" "vpc_master" {
  provider = aws.region-master
  # Using the alias name from the providers.tf file.
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins-master-vpc"
  }

}
# Create VPC in eu-west-1
resource "aws_vpc" "vpc_worker_ireland" {
  provider = aws.region-worker
  # Using the alias name from the providers.tf file.
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins-worker-vpc"
  }
}




#Create AWS Internet Gateway in eu-west-2
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  #ID linked to aws_vpc.vpc_master resource
}

#Create AWS Internet Gateway in eu-west-2
resource "aws_internet_gateway" "igw_ireland" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker_ireland.id
  #ID linked aws_vpc.vpc_worker_ireland resource
}

#Get all availability zones in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"

}

#Create first subnet in eu-west-2
resource "aws_subnet" "master_subnet_1" {
  provider           = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id             = aws_vpc.vpc_master.id
  cidr_block         = "10.0.1.0/24"
}

#Create first subnet in eu-west-2
resource "aws_subnet" "master_subnet_2" {
  provider           = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id             = aws_vpc.vpc_master.id
  cidr_block         = "10.0.2.0/24"
}

#Create subnet in eu-west-1
resource "aws_subnet" "worker_subnet_1" {
  provider   = aws.region-worker
  vpc_id     = aws_vpc.vpc_worker_ireland.id
  cidr_block = "192.168.1.0/24"
}