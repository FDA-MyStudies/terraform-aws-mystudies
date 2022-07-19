
# Example AWS S3 backend state storage

/*
terraform {
  backend "s3" {
    bucket  = "my_special_bucket_name"
    key     = "mystudies/dev/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
*/

provider "aws" {
  region = local.region
}



locals {
  region = "us-west-2"
}

module "mystudies" {
  source = "../.."

  debug = var.debug

  alt_alb_ssl_cert_arn             = var.alt_alb_ssl_cert_arn
  alb_ssl_policy                   = var.alb_ssl_policy
  base_domain                      = var.base_domain
  bastion_enabled                  = var.bastion_enabled
  bastion_instance_type            = var.bastion_instance_type
  bastion_user                     = var.bastion_user
  bastion_user_data                = var.bastion_user_data
  create_certificate               = var.create_certificate
  common_tags                      = var.common_tags
  database_subnets                 = var.database_subnets
  formation                        = var.formation
  formation_type                   = var.formation_type
  install_script_repo_branch       = var.install_script_repo_branch
  install_script_repo_url          = var.install_script_repo_url
  bastion_private_key              = var.bastion_private_key
  office_cidr_A                    = var.office_cidr_A
  office_cidr_B                    = var.office_cidr_B
  private_key_path                 = var.private_key_path
  private_subnets                  = var.private_subnets
  public_subnets                   = var.public_subnets
  registration_snapshot_identifier = var.registration_snapshot_identifier
  registration_use_rds             = var.registration_use_rds
  response_snapshot_identifier     = var.response_snapshot_identifier
  response_ebs_size                = var.response_ebs_size
  appserver_private_key            = var.appserver_private_key
  response_use_rds                 = var.response_use_rds
  security_group_ids               = var.security_group_ids
  subnet_id                        = var.subnet_id
  use_common_rds_subnet_group      = var.use_common_rds_subnet_group
  vpc_cidr                         = var.vpc_cidr
  wcp_snapshot_identifier          = var.wcp_snapshot_identifier
  wcp_use_rds                      = var.wcp_use_rds

}
