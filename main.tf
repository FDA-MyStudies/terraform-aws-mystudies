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
  # Note: TF State backend configured via state.tf.template
}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # vpc_id             = var.vpc_id == null ? module.vpc.vpc_id : var.vpc_id
  # vpc_id = var.vpc_id
  # private_subnet_ids = coalescelist(module.vpc.private_subnets, var.private_subnet_ids, [""])
  # public_subnet_ids  = coalescelist(module.vpc.public_subnets, var.public_subnet_ids, [""])



  # name_prefix = var.formation
  # name_type   = var.formation_type
  # env_dns     = var.base_domain

  additional_tags = merge(
    var.common_tags,
    tomap({
      Formation = var.formation
    })
  )

  # instance_type = "t3a.large"

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

#   #create_vpc = var.vpc_id == null

#   name = "${local.name_prefix}-vpc"
#   cidr = var.vpc_cidr

#   azs = [
#     data.aws_availability_zones.available.names[0],
#     data.aws_availability_zones.available.names[1],
#     data.aws_availability_zones.available.names[2],
#   ]

#   private_subnets = var.private_subnets
#   public_subnets  = var.public_subnets

#   enable_nat_gateway = true
#   single_nat_gateway = true

#   # Default security group - ingress/egress rules cleared to deny all
#   manage_default_security_group  = true
#   default_security_group_ingress = []
#   default_security_group_egress  = []

#   # required for resolution of EFS mount hostname
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = merge(
#     local.additional_tags,
#     {
#       Name = "${local.name_prefix}-${local.name_type}-vpc"
#     },
#   )
# }

# module "endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   version = ">= 3.0.0"

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   security_group_ids = [
#     module.https_private_sg.security_group_id,
#     module.office_ssh_sg.security_group_id,
#   ]

#   endpoints = {
#     ssm = {
#       service             = "ssm"
#       private_dns_enabled = true
#       tags = merge(
#         local.additional_tags,
#         {
#           Name = "${local.name_prefix}-${local.name_type}-ssm-endpoint"
#         },
#       )
#     },
#   }

#   tags = local.additional_tags
# }

# module "lb_http_sg" {
#   source  = "terraform-aws-modules/security-group/aws//modules/http-80"
#   version = ">= 4.3.0"

#   name        = "${var.formation}-${var.formation_type}-alb-http"
#   vpc_id      = module.vpc.vpc_id
#   description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"

#   ingress_cidr_blocks = ["0.0.0.0/0"]

#   tags = local.additional_tags
# }

# module "lb_https_sg" {
#   source  = "terraform-aws-modules/security-group/aws//modules/https-443"
#   version = ">= 4.3.0"

#   name        = "${var.formation}-${var.formation_type}-alb-https"
#   vpc_id      = module.vpc.vpc_id
#   description = "Security group with HTTPS ports open for everybody (IPv4 CIDR), egress ports are all world open"

#   ingress_cidr_blocks = ["0.0.0.0/0"]

#   tags = local.additional_tags
# }

# module "https_private_sg" {
#   source  = "terraform-aws-modules/security-group/aws//modules/https-443"
#   version = ">= 4.3.0"

#   name        = "${var.formation}-${var.formation_type}-private-https"
#   vpc_id      = module.vpc.vpc_id
#   description = "Security group with HTTPS ports open for private VPC subnets"

#   ingress_cidr_blocks = var.private_subnets

#   tags = local.additional_tags
# }

# module "office_ssh_sg" {
#   source  = "terraform-aws-modules/security-group/aws//modules/ssh"
#   version = ">= 4.3.0"

#   # skip creation if user has supplied own security groups list
#   #create = local.create_sg

#   name   = "${local.name_prefix}-ssh-sg"
#   vpc_id = module.vpc.vpc_id
#   #  vpc_id = var.vpc_id

#   description = "Security group with SSH ports open for office/VPN (IPv4 CIDRs)"

#   ingress_cidr_blocks = tolist([var.office_cidr_A, var.office_cidr_B])

#   tags = merge(
#     local.additional_tags,
#     {
#       Name = "${local.name_prefix}-ssh-sg"
#     },
#   )
# }


# # use existing DNS Zone provided by var.base.domain
# data "aws_route53_zone" "env_zone" {
#   name = var.base_domain
# }



# /* Example to create ACM vs use supplied existing certificate
# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = ">= 3.2.0"

#   domain_name = "*.${local.env_dns}"
#   zone_id     = data.aws_route53_zone.env_zone.id

#   validation_method    = "DNS"
#   validate_certificate = true
#   wait_for_validation  = false

#   subject_alternative_names = var.formation_type == "prod" ? ["*.${var.base_domain}"] : []

#   tags = local.additional_tags
# }
# */





# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = ">= 6.5.0"

#   depends_on = [
#     module.vpc,
#   ]

#   name = "${var.formation}-vpc-${var.formation_type}-alb"

#   load_balancer_type = "application"

#   idle_timeout = 600

#   vpc_id  = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets

#   security_groups = [
#     module.lb_http_sg.security_group_id,
#     module.lb_https_sg.security_group_id,
#   ]

#   http_tcp_listeners = [
#     {
#       port        = 80
#       protocol    = "HTTP"
#       action_type = "redirect"
#       redirect = {
#         port        = 443
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#   ]

#   tags = local.additional_tags
# }

# resource "aws_alb_target_group" "default_target" {
#   name     = "${var.formation_type}-vpc-${var.formation}-default"
#   port     = 443
#   protocol = "HTTPS"
#   vpc_id   = module.vpc.vpc_id

#   tags = local.additional_tags
# }

# resource "aws_alb_listener" "alb_https_listener" {
#   load_balancer_arn = module.alb.lb_arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = var.alb_ssl_policy
#   certificate_arn   = var.alb_ssl_cert_arn

#   default_action {
#     target_group_arn = aws_alb_target_group.default_target.arn
#     type             = "forward"
#   }
# }


# locals {
#   security_groups = local.create_sg ? [module.ssh_sg.security_group_id] : var.security_groups
# }

###
#
# Server EC2 instances
#
###

locals {
  shortname_suffix       = "eaa8e0e5"
  response_dns_shortname = "response-${local.shortname_suffix}"
}

data "aws_route53_zone" "this" {
  name = var.base_domain
}

resource "aws_route53_record" "response" {
  # count = var.create_dns_record_response ? 1 : 0

  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${local.response_dns_shortname}.${var.base_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.response.public_ip]
}

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
# data "aws_security_group" "selected" {
#   for_each = toset(flatten([var.security_group_ids]))
#   id       = each.key
# }

resource "aws_instance" "response" {

  ami = var.ami == null ? data.aws_ami.ubuntu.id : var.ami

  instance_type = var.instance_type

  # key_name = module.keypair["response"].key_pair_key_name
  key_name = var.keypair_name

  subnet_id = var.subnet_id

  # security_groups = data.aws_security_group.selected.*.name
  security_groups = flatten([var.security_group_ids])

  tags = merge(
    local.additional_tags,
    {
      Name = "${var.formation}-response"
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

            CERT_CN = "${local.response_dns_shortname}.${var.base_domain}"

            LABKEY_DEFAULT_DOMAIN  = "${local.response_dns_shortname}.${var.base_domain}"
            LABKEY_BASE_SERVER_URL = "https://${local.response_dns_shortname}.${var.base_domain}"

            LABKEY_SYSTEM_DESCRIPTION = "MyStudies Response Server"

            TOMCAT_INSTALL_TYPE = "Embedded"

            POSTGRES_SVR_LOCAL = "TRUE"
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


