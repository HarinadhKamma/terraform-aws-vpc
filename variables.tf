variable "vpc_cidr" {
  type        = string
  description = "vpc cidr range "
}

variable "project_name" {
  type        = string
  description = "project name "
}

variable "environment" {
  type        = string
  description = "enironment name "
}

variable "public_subnet_cidr" {
  type        = list
  description = "public subnet cidr rane"
}

variable "private_subnet_cidr" {
  type        = list
  description = "private subnet cidr rane"
}

variable "database_subnet_cidr" {
  type        = list
  description = "private subnet cidr rane"
}

variable "vpc_peering_connection" {
  type    = bool
  default = true
}



variable "tags" {
  type = map
  default = {

  }
}

variable "igw_tags" {
  type = map
  default = {

  }

}
