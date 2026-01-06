locals {
  common_tags = {
    project_name = var.project_name
    Terraform    = true
    Environment  = var.environment
  }
  common_name = "${var.project_name}-${var.environment}"
  az_names    = slice(data.aws_availability_zones.available.names, 0, 2)
  project_tags = merge(local.common_tags, {
    Name = local.common_name
  })

}

