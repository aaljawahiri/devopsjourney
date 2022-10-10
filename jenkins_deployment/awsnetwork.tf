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
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}

#Create second subnet in eu-west-2
resource "aws_subnet" "master_subnet_2" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
}

#Create subnet in eu-west-1
resource "aws_subnet" "worker_subnet_1" {
  provider   = aws.region-worker
  vpc_id     = aws_vpc.vpc_worker_ireland.id
  cidr_block = "192.168.1.0/24"
}

#Initate Peering connection request from eu-west-1
resource "aws_vpc_peering_connection" "euwest1-euwest2" {

  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_worker_ireland.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region-worker

}
#Accept VPC peering request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.euwest1-euwest2.id
  auto_accept               = true

}

#Crete route table in us-east-1
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.euwest1-euwest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }

}


#Overwrite default route table of VPC(Master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id

}

#Create route table in us-west-2
resource "aws_route_table" "internet_route_ireland" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker_ireland.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_ireland.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.euwest1-euwest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-Region-RT"
  }
}

#Overwrite default route table of VPC(Worker) with our route table entries
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_worker_ireland.id
  route_table_id = aws_route_table.internet_route_ireland.id

}