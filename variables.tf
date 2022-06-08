variable "AMI1" {
    type = map
    default = {
        AmazonLinux = "ami-0e5a288df830e9b56"
        #Ubuntu = "ami-0641bed8c0ce71686"
        #eu-north-1 = "ami-0e5a288df830e9b56"
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
