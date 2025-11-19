# PROVIDER
provider "aws" {
  region = "us-east-2"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Trendstore-vpc"
  }
}

# SUBNETS

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-2a"

    tags = {
    Name = "public-subnet"
  }
}

# INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Trendstore-igw"
  }
}

# ROUTE TABLE

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    
    tags = {
        Name = "public-rt"
    }
}

# ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

# SECURITY GROUP

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# IAM ROLE + INSTANCE PROFILE

resource "aws_iam_role" "ec2_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 INSTANCE

resource "aws_instance" "jenkins" {
  ami           = "ami-0f5fcdfbd140e4ab7" 
  instance_type = "t2.medium"

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = "gokul"

  user_data = <<-EOF
  #!/bin/bash

  apt-get update -y
  apt-get upgrade -y

  apt-get install -y openjdk-17-jdk

  java -version

  curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

  apt-get update -y

  apt-get install -y jenkins

  systemctl enable jenkins
  systemctl start jenkins
  systemctl status jenkins -n 20
  EOF


  tags = {
    Name = "jenkins-server"
  }
}

# OUTPUTS

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}