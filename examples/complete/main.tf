#
# Copyright (c) 2021 LabKey Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provider "aws" {
  region = local.region
}

locals {
  region = "us-west-2"

  formation = "our-studies"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.7.0"

  name = "${local.formation}-vpc"
  cidr = "10.0.0.0/16"

  azs = ["${local.region}a", "${local.region}b"]

  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.10.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = true

  tags = {
    Formation = local.formation
  }
}

module "mystudies" {
  source = "../.."

  debug            = var.debug
  private_key_path = var.private_key_path

  install_script_repo_url    = var.install_script_repo_url
  install_script_repo_branch = var.install_script_repo_branch

  subnet_id = element(module.vpc.private_subnets, 0)
}
