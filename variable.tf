variable "region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  type    = string
  default = "10.0.2.0/24"
}

variable "availability_zone" {
  type    = string
  default = "us-west-2a"
}

variable "instance_ami" {
  type    = string
  default = "ami-0fcf52bcf5db7b003"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}


