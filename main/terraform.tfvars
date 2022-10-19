######### Networking #############
vpc_cidr_block = "10.0.0.0/16"
map_az_subnet = {
    "ap-east-1a" = 1
    "ap-east-1b" = 2
    "ap-east-1c" = 3
}

######### ELB #############
name = "huyls"
instance_type = "t3.medium"
key_pair = "huyls"
#image_id = "ami-0b2c91ed65ccbb775"
image_id = "ami-09800b995a7e41703"