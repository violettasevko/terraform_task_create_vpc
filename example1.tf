resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = "true"
  instance_tenancy = "default"

  tags = {
    Name = "lunavpc"
  }
}

resource "aws_subnet" "subnet-public" {
    for_each = var.availability_zones

    vpc_id = "${aws_vpc.main.id}"

    availability_zone = each.key
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value)
    ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, each.value + 6)
    map_public_ip_on_launch = "true" //it makes this a public subnet
    assign_ipv6_address_on_creation = true

    tags = {
        Name = "subnet-public-${each.value}"
    }
}

resource "aws_subnet" "subnet-private" {
    for_each = var.availability_zones
    
    vpc_id = "${aws_vpc.main.id}"
    
    availability_zone = each.key
    cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, each.value + 10)
    map_public_ip_on_launch = "true" //it makes this a public subnet
    
    tags = {
        Name = "subnet-private-${each.value + 10}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"
    tags = {
        Name = "igw"
    }
}

resource "aws_route_table" "public-rt" {
    vpc_id = "${aws_vpc.main.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.igw.id}" 
    }
    
    tags = {
        Name = "public-rt"
    }
}

resource "aws_route_table_association" "rta-public-subnet"{
    for_each = var.availability_zones
    subnet_id = aws_subnet.subnet_public[each.key].id
    route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_security_group" "webserver" {
    vpc_id = "${aws_vpc.main.id}"
    name = "Webserver"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
        description = "access all ipv4"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        ipv6_cidr_blocks = ["::/0"]
        description = "access all ipv6"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH port for all ipv4"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        ipv6_cidr_blocks = ["::/0"]
        description = "SSH port for all ipv6"
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP port for all ipv4"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        ipv6_cidr_blocks = ["::/0"]
        description = "HTTP port for all ipv6"
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS port"
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        ipv6_cidr_blocks = ["::/0"]
        description = "HTTPS port"
    }
    tags = {
        Name = "webserver"
    }
}

resource "aws_instance" "vpcvpc" {
    ami = "${lookup(var.AMI, var.AWS_Region)}"
    instance_type = var.instance_type
    # VPC
    subnet_id = "${aws_subnet.subnet-public["eu-north-1a"].id}"
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
    # the Public SSH key
    key_name = var.web1_key_name
    tags = {
       Name = "AmazonLinux"
    }
}
#
#resource "aws_instance" "web2" {
#    ami = "${lookup(var.AMI, var.AWS_Region)}"
#    instance_type = var.instance_type
#    # VPC
#    subnet_id = "${aws_subnet.subnet-public["eu-central-1b"].id}"
#    # Security Group
#    vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
#    # the Public SSH key
#    key_name = var.web2_key_name
#    tags = {
#       Name = "AmazonLinux"
#    }
#}
