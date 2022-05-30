
# 
variable "ami" {
  type = map

  default = {
      #should be one red hat linux, 1 ubuntu, 1 amazon linux 2
    "us-east-1" = "ami-0f095f89ae15be883" #red hat linux
    "us-east-1" = "ami-09d56f8956ab235b3" #ubuntu
    "us-east-1" = "ami-0015e2919fee4ad7e" #amazon linux 2/centos
  }
}
variable "azcount" {
  default  = [0,1,2]

} 


variable "instance_count" {
  default = "3"
}

variable "instance_tags" {
  type = list
  default = ["Terraform-1", "Terraform-2", "Terraform-3"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "aws_region" {
  default = "us-east-1"
}

# variable "vpc-cidr" {
# default = "10.0.0.0/16"
# description = "VPC CIDR BLOCK"
# type = string
# }

# variable "Public_Subnet" {
# default = "10.0.0.0/16"
# description = "Public_Subnet"
# type = string
# }

variable subnetcidr {
    default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.4.0/24"]
}

# variable "Private_Subnet_1" {
# default = "10.0.2.0/24"
# description = "Private_Subnet_1"
# type = string
# }


#get my IP for ssh
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
