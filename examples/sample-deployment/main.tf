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
}
