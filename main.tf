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

terraform {
  required_version = "~> 1"

  required_providers {
    aws = {
      source = "hashicorp/aws"

      # latest as of 08/23/21
      version = ">= 3.55.0"
    }
  }
}

# data "aws_availability_zones" "available" {
#   state = "available"
# }

locals {
  # vpc_id             = var.vpc_id == null ? module.vpc.vpc_id : var.vpc_id
  # vpc_id = var.vpc_id
  # private_subnet_ids = coalescelist(module.vpc.private_subnets, var.private_subnet_ids, [""])
  # public_subnet_ids  = coalescelist(module.vpc.public_subnets, var.public_subnet_ids, [""])



  name_prefix = "mystudies"

  additional_tags = {
    Prefix = local.name_prefix
  }

  instance_type = "t3a.large"

  # values for labkey install script(s)
  labkey_company_name = "MyStudies Reference Deployment"
  labkey_app_home     = "/labkey"
  labkey_files_root   = "/labkey/labkey/"

  # values for wcp install script(s)
}

###
#
# Networking
#
###

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = ">= 3.6.0"

#   create_vpc = var.vpc_id == null

#   name = "${local.name_prefix}-vpc"
#   cidr = var.cidr

#   azs = [
#     data.aws_availability_zones.available.names[0],
#     data.aws_availability_zones.available.names[1],
#   ]

#   private_subnets = var.private_subnets
#   public_subnets  = var.public_subnets

#   enable_nat_gateway = true
#   single_nat_gateway = true

#   # required for resolution of EFS mount hostname
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = merge(
#     local.additional_tags,
#     {
#       Name = "${local.name_prefix}-vpc"
#     },
#   )
# }

# module "ssh_sg" {
#   source  = "terraform-aws-modules/security-group/aws//modules/ssh"
#   version = ">= 4.3.0"

#   # skip creation if user has supplied own security groups list
#   create = local.create_sg

#   name = "${local.name_prefix}-ssh-sg"
#   # vpc_id = module.vpc.vpc_id
#   vpc_id = var.vpc_id

#   description = "Security group with SSH ports open for office/VPN (IPv4 CIDRs)"

#   ingress_cidr_blocks = [
#     "0.0.0.0"
#   ]

#   tags = merge(
#     local.additional_tags,
#     {
#       Name = "${local.name_prefix}-ssh-sg"
#     },
#   )
# }

# locals {
#   security_groups = local.create_sg ? [module.ssh_sg.security_group_id] : var.security_groups
# }

###
#
# Server EC2 instances
#
###

# find the latest Ubuntu AMI for use in aws_instances below
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # canonical
  owners = ["099720109477"]
}

resource "aws_instance" "response" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type

  # key_name = module.keypair["response"].key_pair_key_name
  key_name = var.keypair_name

  subnet_id = var.subnet_id

  # security_groups = flatten([module.alb_https_sg.this_security_group_id, module.alb_http_sg.this_security_group_id, var.security_group_ids])
  security_groups = flatten([var.security_group_ids])

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-response"
    },
  )

  lifecycle {
    ignore_changes = [tags]
  }

  connection {
    type = "ssh"
    user = "ubuntu"

    # must either be the key named above for creating the instance
    private_key = file(var.private_key_path)

    # host = private_dns
    host = aws_instance.response.public_dns

    # bastion_host        = local.bastion_host
    # bastion_user        = local.bastion_user
    # bastion_private_key = local.bastion_key
  }

  provisioner "remote-exec" {
    inline = [
      templatefile(
        "${path.module}/install-script-warpper.tmpl",
        {
          script_name = "labkey"
          debug       = var.debug
          environment = {
            LABKEY_APP_HOME     = local.labkey_app_home
            LABKEY_FILES_ROOT   = local.labkey_files_root
            LABKEY_COMPANY_NAME = local.labkey_company_name

            LABKEY_BASE_SERVER_URL = "https://localhost"

            LABKEY_SYSTEM_DESCRIPTION = "MyStudies Response Server"

            TOMCAT_INSTALL_TYPE = "Standard"
          }
          url    = var.install_script_repo_url
          branch = var.install_script_repo_branch
        }
      )
    ]
  }
}

# resource "aws_instance" "registration" {

#   ami           = data.aws_ami.ubuntu.id
#   instance_type = local.instance_type

#   tags = merge(
#     var.additional_tags,
#     {
#       Name = "${local.name_prefix}-${each.key}"
#     },
#   )

#   lifecycle {
#     ignore_changes = [tags]
#   }

#   provisioner "remote-exec" {
#     inline = <<EOT
#       ./install-labkey.bash
#     EOT
#   }
# }

# resource "aws_instance" "wcp" {

#   ami           = data.aws_ami.ubuntu.id
#   instance_type = local.instance_type

#   tags = merge(
#     var.additional_tags,
#     {
#       Name = "${local.name_prefix}-${each.key}"
#     },
#   )

#   lifecycle {
#     ignore_changes = [tags]
#   }

#   provisioner "remote-exec" {
#     inline = <<EOT
#       ./install-wcp.bash
#     EOT
#   }
# }
