variable "AMI1" {
    type = map
    default = {
        AmazonLinux = "ami-08bdc08970fcbd34a"
        Ubuntu = "ami-01ded35841bc93d7f"
    }
}

variable "AWS_Region" {
    default = "eu-north-1"
}

variable "instance_type" {
    default = "t4g.micro"
}

variable "vpc_cidr_block" {
    default = "10.10.0.0/16"
}

variable "availability_zones" {
    default = {
        eu-north-1a = 1
        eu-north-1b = 2
        eu-north-1c = 3
    }
}

variable "web_key_name" {
    default = "lunakey"
}
