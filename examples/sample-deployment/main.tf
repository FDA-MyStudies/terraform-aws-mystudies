

provider "aws" {
  region = local.region
}



locals {
  region = "us-west-2"
}

module "mystudies" {
  source = "../.."

  debug = var.debug

  install_script_repo_url    = var.install_script_repo_url
  install_script_repo_branch = var.install_script_repo_branch

  keypair_name       = var.keypair_name
  private_key_path   = var.private_key_path
  security_group_ids = var.security_group_ids
  subnet_id          = var.subnet_id
  formation          = var.formation
  formation_type     = var.formation_type
  common_tags        = var.common_tags
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  vpc_cidr           = var.vpc_cidr
  office_cidr_A      = var.office_cidr_A
  office_cidr_B      = var.office_cidr_B
  alb_ssl_cert_arn   = var.alb_ssl_cert_arn
  alb_ssl_policy     = var.alb_ssl_policy

}
