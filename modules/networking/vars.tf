variable "vpc_cidr_block" {
  type = string
}

variable "name" {
  type = string
}

variable "map_az_subnet" { 
  type = map 
  default = {
    "ap-east-1a" = "10.0.1.0/24"
    "ap-east-1b" = "10.0.2.0/24"
    "ap-east-1c" = "10.0.3.0/24"
  }
}

