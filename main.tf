provider "aws" {
    region = "eu-west-1"
}

# create a VPC
#resource "aws_vpc" "app_vpc" {
#    cidr_block = "10.0.0.0/16"
#    tags = {
#        Name = "Maksaud-eng54-app_vpc"
#    }
#}


# Use devops vpc
    # vpc-07e47e9d90d2076da
# Create new subnet
# move instance into subnet
resource "aws_subnet" "app_subnet" {
    vpc_id = var.vpc_id
    cidr_block = "172.31.85.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name = var.name
    }
}

# Route table
resource "aws_route_table" "public" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = data.aws_internet_gateway.default-gw.id
    }

    tags = {
        Name = "${var.name}-public"
    }

}

resource "aws_route_table_association" "assoc" {
    subnet_id = aws_subnet.app_subnet.id
    route_table_id = aws_route_table.public.id
}



# We don't need a new IG -
# We can query our exist vpc/infrastructure with the 'data' handler/function
data "aws_internet_gateway" "default-gw" {
    filter {
        name = "attachment.vpc-id"
        values = [var.vpc_id]
    }
  
}


# Launching an instance
resource "aws_instance" "app_instance" {
    ami = "ami-040bb941f8d94b312"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = aws_subnet.app_subnet.id
    vpc_security_group_ids = [aws_security_group.allow_port80.id]
    tags = {
        Name = "eng54-Maksaud-app-tf"
    }
}

resource "aws_security_group" "allow_port80" {
  name        = "Maksaud-eng54-security-group"
  description = "Allow port 80 inbound traffic"
  vpc_id      = "vpc-07e47e9d90d2076da"

  ingress {
    description = "port 80 from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = "Maksaud-eng54-security-group"
  }
}
