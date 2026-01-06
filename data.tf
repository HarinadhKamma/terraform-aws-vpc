data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to retrieve the *default* VPC
data "aws_vpc" "default" {
  default = true
}
