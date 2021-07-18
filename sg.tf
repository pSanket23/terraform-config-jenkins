resource "aws_security_group" "prod_pub_sg" {
    
    name = "prod_pub_sg"
    description = "Security Group for CI/CD Instances"
    vpc_id = aws_vpc.prod_vpc.id

    ingress {
        description = "Allow ssh"
        from_port = "22"
        to_port = "22"
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description = "Inbound traffic"
        from_port = "8080"
        to_port = "8080"
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description = "Inbound traffic"
        from_port = "80"
        to_port = "80"
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        description = "Out bound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "prod_pri_sg" {
    
    name = "prod_pri_sg"
    description = "Security Group for Application Instances"
    vpc_id = aws_vpc.prod_vpc.id

    ingress {
        description = "Allow ssh"
        from_port = "22"
        to_port = "22"
        protocol         = "tcp"
        cidr_blocks      = ["172.20.10.0/24"]
    }

    ingress {
        description = "Inbound traffic"
        from_port = "8080"
        to_port = "8080"
        protocol         = "tcp"
        cidr_blocks      = ["172.20.10.0/24"]
    }

    ingress {
        description = "Inbound traffic"
        from_port = "80"
        to_port = "80"
        protocol         = "tcp"
        cidr_blocks      = ["172.20.10.0/24"]
    }

    egress {
        description = "Out bound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}