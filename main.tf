provider aws {
    region = var.region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

# Prod Virual Private Cloud
resource "aws_vpc" "prod_vpc" {
    cidr_block = "172.20.0.0/16"
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
    instance_tenancy = "default"

    tags = {
        Name = "prod-vpc"
    }
}

# Public subnet 
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.prod_vpc.id
    cidr_block = "172.20.10.0/24"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "public_subnet"
    }
}

# Private subnet 
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.prod_vpc.id
    cidr_block = "172.20.20.0/24"
    map_public_ip_on_launch = "false"

    tags = {
        Name = "private_subnet"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.prod_vpc.id

    tags = {
        Name = "IGW"
    }
}

# Route Table for Internet Gateway associated to Public subnet
resource "aws_route_table" "prod_pub_crt" {
    vpc_id = aws_vpc.prod_vpc.id

    route {
        # Public subnet can reach everywhere
        cidr_block = "0.0.0.0/0"

        # IGW to reach internet
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "prod_pub_crt"
    }
}

# Associate CRT to public subnet
resource "aws_route_table_association" "prod_crta_pub_subnet" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.prod_pub_crt.id
}

#Elastic IP for NAT Gateway
resource "aws_eip" "nat_gw_eip" {
    depends_on = [
        aws_route_table_association.prod_crta_pub_subnet
    ]
    vpc = true
}

# NAT Gateway in Public Subnet
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_gw_eip.id 
    subnet_id     = aws_subnet.public_subnet.id

    tags = {
        Name = "nat_gw"
    }

    # Depends on the Internet Gateway for the VPC.
    depends_on = [aws_internet_gateway.igw]
}

# Route Table for NAT Gateway associated to Private subnet
resource "aws_route_table" "prod_pri_crt" {
    vpc_id = aws_vpc.prod_vpc.id

    route {
        # Private subnet can reach everywhere
        cidr_block = "0.0.0.0/0"

        # IGW to reach internet
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }

    tags = {
        Name = "prod_pri_crt"
    }
}

# Associate CRT to private subnet
resource "aws_route_table_association" "prod_crta_pri_subnet" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.prod_pri_crt.id
}

# SSH Key pair
resource "aws_key_pair" "key_pair" {
    key_name = "ec2_key_pair"
    public_key = var.ec2_public_key
}

# EC2 instance as CI/CD box (Public Subnet)
resource "aws_instance" "prod_cicd" {
    #ami = data.aws_ami.amazon_linux.id
    ami = "ami-0b0af3577fe5e3532"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.prod_pub_sg.id]
    user_data = data.template_file.cicd_user_data.template
    key_name = aws_key_pair.key_pair.key_name
    
    tags = {
      "Name" = "prod_cicd"
    }
}

# EC2 instance as App box (Private Subnet)
resource "aws_instance" "prod_app" {
    #ami = data.aws_ami.amazon_linux.id
    ami = "ami-0b0af3577fe5e3532"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.private_subnet.id
    vpc_security_group_ids = [aws_security_group.prod_pri_sg.id]
    #user_data = data.template_file.app_user_data
    key_name = aws_key_pair.key_pair.key_name
    
    tags = {
      "Name" = "prod_app"
    }
}
