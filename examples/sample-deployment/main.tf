
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

  alb_ssl_policy                            = var.alb_ssl_policy
  alt_alb_ssl_cert_arn                      = var.alt_alb_ssl_cert_arn
  appserver_private_key                     = var.appserver_private_key
  base_domain                               = var.base_domain
  bastion_enabled                           = var.bastion_enabled
  bastion_instance_type                     = var.bastion_instance_type
  bastion_private_key                       = var.bastion_private_key
  bastion_user                              = var.bastion_user
  bastion_user_data                         = var.bastion_user_data
  common_tags                               = var.common_tags
  create_certificate                        = var.create_certificate
  database_subnets                          = var.database_subnets
  formation                                 = var.formation
  formation_type                            = var.formation_type
  install_script_repo_branch                = var.install_script_repo_branch
  install_script_repo_url                   = var.install_script_repo_url
  office_cidr_A                             = var.office_cidr_A
  office_cidr_B                             = var.office_cidr_B
  private_key_path                          = var.private_key_path
  private_subnets                           = var.private_subnets
  public_subnets                            = var.public_subnets
  registration_ebs_data_snapshot_identifier = var.registration_snapshot_identifier
  registration_ebs_size                     = var.registration_ebs_size
  registration_snapshot_identifier          = var.registration_snapshot_identifier
  registration_target_group_path            = var.registration_target_group_path
  registration_use_rds                      = var.registration_use_rds
  response_ebs_data_snapshot_identifier     = var.response_ebs_data_snapshot_identifier
  response_ebs_size                         = var.response_ebs_size
  response_snapshot_identifier              = var.response_snapshot_identifier
  response_target_group_path                = var.response_target_group_path
  response_use_rds                          = var.response_use_rds
  security_group_ids                        = var.security_group_ids
  subnet_id                                 = var.subnet_id
  use_common_rds_subnet_group               = var.use_common_rds_subnet_group
  vpc_cidr                                  = var.vpc_cidr
  wcp_create_ec2                            = var.wcp_create_ec2
  wcp_ebs_data_snapshot_identifier          = var.wcp_ebs_data_snapshot_identifier
  wcp_ebs_size                              = var.wcp_ebs_size
  wcp_snapshot_identifier                   = var.wcp_snapshot_identifier
  wcp_target_group_path                     = var.wcp_target_group_path
  wcp_use_rds                               = var.wcp_use_rds

}
