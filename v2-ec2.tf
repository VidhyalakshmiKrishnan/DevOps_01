provider "aws" {
    region ="eu-north-1"  
}

resource "aws_instance" "demo-server" {

ami="ami-08f78cb3cc8a4578e"
instance_type = "t3.micro"
key_name = "dpp"
//security_groups = [ "demo-sg" ]
subnet_id = aws_subnet.dpp-public-subnet-01.id
vpc_security_group_ids = [aws_security_group.demo-sg.id]
for_each = [ "Jenkins-master", "Build-slave" ,"Ansible" ]
tags = {
  name = "${each.key}" 
}

}

resource "aws_security_group" "demo-sg" {

    name = "demo-sg"
    description ="SSH - Access"
    vpc_id = aws_vpc.dpp-vpc.id

    ingress {
        description = "SSH Access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]


    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

  tags ={

    Name= "SSH-prot"
  }
}

resource "aws_vpc" "dpp-vpc" {
        
        cidr_block = "10.1.0.0/16"
        tags = {
          name= "dpp-vpc"
        }
}

resource "aws_subnet" "dpp-public-subnet-01" {
  
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    name= "dpp-public-subnet-01"
  }

}
resource "aws_subnet" "dpp-public-subnet-02" {
  
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "eu-north-1b"
  map_public_ip_on_launch = true
  tags = {
    name= "dpp-public-subnet-02"
  }

}
resource "aws_internet_gateway" "dpp-igw" {
  
  vpc_id = aws_vpc.dpp-vpc.id
  tags = {
    name="dpp-igw"
  }

}

resource "aws_route_table" "dpp-public-rt" {
    vpc_id = aws_vpc.dpp-vpc.id
    route  {
        cidr_block="0.0.0.0/0"
        gateway_id= aws_internet_gateway.dpp-igw.id
    }
    tags = {
        name= "dpp-public-rt"
    }
  
}

resource "aws_route_table_association" "dpp-rta-public-subnet01" {

    route_table_id = aws_route_table.dpp-public-rt.id 
    subnet_id=aws_subnet.dpp-public-subnet-01.id
}

resource "aws_route_table_association" "dpp-rta-public-subnet02" {

    route_table_id = aws_route_table.dpp-public-rt.id 
    subnet_id=aws_subnet.dpp-public-subnet-02.id
}