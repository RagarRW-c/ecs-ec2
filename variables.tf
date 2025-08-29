variable "project_name" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.60.0.0/24", "10.60.1.0/24"]
}

variable "private_cidrs" {
  type    = list(string)
  default = ["10.60.10.0/24", "10.60.11.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "min_size" {
  type    = number
  default = 1
}


variable "key_name" {
  type    = string
  default = null #jesli SSH
}
