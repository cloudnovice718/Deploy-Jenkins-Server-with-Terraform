variable "profile" {
  type    = string
  default = "default"
}

variable "region-alpha" {
  type    = string
  default = "us-east-1"
}

variable "region-bravo" {
  type    = string
  default = "us-west-2"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "vpc_alpha_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

variable "vpc_bravo_cidr_block" {
  type    = string
  default = "192.168.1.0/24"
}

variable "ami_name" {
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "workers_count" {
  type    = number
  default = 1
}

variable "web_port" {
  type    = number
  default = 8080
}

variable "dns_name" {
  type    = string
  default = "cloudnovice718.com."
}

