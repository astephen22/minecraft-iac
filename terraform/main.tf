##################################
# VPC
##################################

resource "aws_vpc" "minecraft_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "minecraft-vpc"
  }
}

##################################
# Subnet
##################################

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.minecraft_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "minecraft-public-subnet"
  }
}

##################################
# Internet Gateway
##################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minecraft_vpc.id

  tags = {
    Name = "minecraft-igw"
  }
}

##################################
# Route Table
##################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.minecraft_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "minecraft-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

##################################
# Security Group
##################################

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg"
  description = "Allow SSH and Minecraft"
  vpc_id      = aws_vpc.minecraft_vpc.id

  ##################################
  # SSH
  ##################################

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ##################################
  # Minecraft
  ##################################

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ##################################
  # Outbound
  ##################################

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "minecraft-sg"
  }
}

##################################
# Find Amazon Linux 2023 AMI
##################################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

##################################
# S3 Bucket
##################################

resource "aws_s3_bucket" "minecraft_backup" {
  bucket = "alex-minecraft-backups-12345"

  tags = {
    Name = "minecraft-backups"
  }
}

##################################
# ECR Repository
##################################

resource "aws_ecr_repository" "minecraft_repo" {
  name = "minecraft-server"
}

##################################
# EC2 Instance
##################################

resource "aws_instance" "minecraft_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = var.key_name

  ##################################
  # REQUIRED FOR AWS ACADEMY
  ##################################

  iam_instance_profile = "LabInstanceProfile"

  ##################################
  # Storage
  ##################################

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "minecraft-server"
  }
}
