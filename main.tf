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



  name_prefix        = var.formation
  name_type          = var.formation_type
  env_dns            = var.base_domain
  ssm_parameter_path = "/${var.formation}/${var.formation_type}"
  additional_tags = merge(var.common_tags, tomap({
    Prefix      = local.name_prefix
    Environment = var.formation_type
    Formation   = var.formation
  }))

  instance_type = "t3a.large"

  # values for labkey install script(s)
  labkey_company_name = "MyStudies Reference Deployment"
  labkey_app_home     = "/labkey"
  labkey_files_root   = "/labkey/labkey/"

  # values for wcp install script(s)
}

###############################################################################################
#
# Networking
#
###############################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.6.0"

  #create_vpc = var.vpc_id == null

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
  ]

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # required for resolution of EFS mount hostname
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-${local.name_type}-vpc"
    },
  )
}

module "endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = ">= 3.0.0"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    module.https_private_sg.security_group_id,
    module.office_ssh_sg.security_group_id,
  ]

  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      tags = merge(
        local.additional_tags,
        {
          Name = "${local.name_prefix}-${local.name_type}-ssm-endpoint"
        },
      )
    },
  }

  tags = local.additional_tags
}

###############################################################################################
#
# Security Groups
#
###############################################################################################

module "lb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = ">= 4.3.0"

  name        = "${var.formation}-${var.formation_type}-alb-http"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = local.additional_tags
}

module "lb_https_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = ">= 4.3.0"

  name        = "${var.formation}-${var.formation_type}-alb-https"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with HTTPS ports open for everybody (IPv4 CIDR), egress ports are all world open"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = local.additional_tags
}

module "https_private_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = ">= 4.3.0"

  name        = "${var.formation}-${var.formation_type}-private-https"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with HTTPS ports open for private VPC subnets"

  ingress_cidr_blocks = var.private_subnets

  tags = local.additional_tags
}

module "office_ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = ">= 4.3.0"

  # skip creation if user has supplied own security groups list
  #create = local.create_sg

  name   = "${local.name_prefix}-ssh-sg"
  vpc_id = module.vpc.vpc_id
  #  vpc_id = var.vpc_id

  description = "Security group with SSH ports open for office/VPN (IPv4 CIDRs)"

  ingress_cidr_blocks = tolist([var.office_cidr_A, var.office_cidr_B])

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-ssh-sg"
    },
  )
}


module "response_psql_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = ">= 4.3.0"

  create = var.response_use_rds
  name   = "${local.name_prefix}-response-psql-sg"
  vpc_id = module.vpc.vpc_id

  description = "Security group for Response Server RDS Instance"

  ingress_cidr_blocks = var.private_subnets

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-response-psql-sg"
    },
  )
}

module "registration_psql_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = ">= 4.3.0"

  create = var.registration_use_rds
  name   = "${local.name_prefix}-registration-psql-sg"
  vpc_id = module.vpc.vpc_id

  description = "Security group for Registration Server RDS Instance"

  ingress_cidr_blocks = var.private_subnets

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-registration-psql-sg"
    },
  )
}

module "wcp_mysql_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/mysql"
  version = ">= 4.3.0"

  create = var.wcp_use_rds
  name   = "${local.name_prefix}-wcp_mysql_sg"
  vpc_id = module.vpc.vpc_id

  description = "Security group for WCP Server RDS Instance"

  ingress_cidr_blocks = var.private_subnets

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-wcp_mysql_sg"
    },
  )
}



# use existing DNS Zone provided by var.base.domain
data "aws_route53_zone" "env_zone" {
  name = var.base_domain
}



/* Example to create ACM vs use supplied existing certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = ">= 3.2.0"

  domain_name = "*.${local.env_dns}"
  zone_id     = data.aws_route53_zone.env_zone.id

  validation_method    = "DNS"
  validate_certificate = true
  wait_for_validation  = false

  subject_alternative_names = var.formation_type == "prod" ? ["*.${var.base_domain}"] : []

  tags = local.additional_tags
}
*/




# Application Load Balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = ">= 6.5.0"

  depends_on = [
    module.vpc,
  ]

  name = "${var.formation}-vpc-${var.formation_type}-alb"

  load_balancer_type = "application"

  idle_timeout = 600

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [
    module.lb_http_sg.security_group_id,
    module.lb_https_sg.security_group_id,
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = local.additional_tags
}

resource "aws_alb_target_group" "default_target" {
  name     = "${var.formation_type}-vpc-${var.formation}-default"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

  tags = local.additional_tags
}

resource "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = module.alb.lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = var.alb_ssl_cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.default_target.arn
    type             = "forward"
  }
}


###############################################################################################
#
# Secrets Management
#
###############################################################################################

resource "aws_kms_key" "env_kms_key" {
  description             = "KMS Encryption Key Used for Secrets Management"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.additional_tags
}

resource "random_password" "resp_database_password" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  min_special = 1
}

resource "aws_ssm_parameter" "resp_database_password" {
  name   = "${local.ssm_parameter_path}/db/resp_db_password"
  type   = "SecureString"
  value  = random_password.resp_database_password.result
  key_id = aws_kms_key.env_kms_key.id
  tags   = local.additional_tags
}

resource "random_password" "resp_rds_master_pass" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  min_special = 1
}

resource "aws_ssm_parameter" "resp_rds_master_pass" {
  name   = "${local.ssm_parameter_path}/db/resp_rds_master_pass"
  type   = "SecureString"
  value  = random_password.resp_rds_master_pass.result
  key_id = aws_kms_key.env_kms_key.id
  tags   = local.additional_tags
}



# Generate Response LabKey Master Encryption Key (MEK)
resource "random_password" "resp_mek" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  special = false
}

resource "aws_ssm_parameter" "resp_mek" {
  name   = "${local.ssm_parameter_path}/mek/resp_mek"
  type   = "SecureString"
  value  = random_password.resp_mek.result
  key_id = aws_kms_key.env_kms_key.id
  tags   = local.additional_tags
}

resource "random_password" "reg_rds_master_pass" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  min_special = 1
}

resource "aws_ssm_parameter" "reg_rds_master_pass" {
  name   = "${local.ssm_parameter_path}/db/reg_rds_master_pass"
  type   = "SecureString"
  value  = random_password.reg_rds_master_pass.result
  key_id = aws_kms_key.env_kms_key.id
  tags   = local.additional_tags
}

resource "random_password" "reg_database_password" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  min_special = 1
}

resource "aws_ssm_parameter" "reg_database_password" {
  name   = "${local.ssm_parameter_path}/db/reg_db_password"
  type   = "SecureString"
  value  = random_password.reg_database_password.result
  key_id = aws_kms_key.env_kms_key.id
  tags   = local.additional_tags
}

# Generate Registration LabKey Master Encryption Key (MEK)
resource "random_password" "reg_mek" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  special = false
}

resource "aws_ssm_parameter" "reg_mek" {
  name   = "${local.ssm_parameter_path}/mek/reg_mek"
  type   = "SecureString"
  value  = random_password.reg_mek.result
  key_id = aws_kms_key.env_kms_key.id
  tags   = local.additional_tags
}


# Mysql max password length is 32
resource "random_password" "wcp_database_password" {
  length      = 30
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  min_special = 1
}

resource "aws_ssm_parameter" "wcp_database_password" {
  name   = "${local.ssm_parameter_path}/db/wcp_db_password"
  type   = "SecureString"
  value  = random_password.wcp_database_password.result
  key_id = aws_kms_key.env_kms_key.id
  tags   = local.additional_tags
}






###############################################################################################
#
# RDS Deployments
#
###############################################################################################

# Response Server
module "resp_db" {
  source                    = "terraform-aws-modules/rds/aws"
  version                   = "~> 3.3.0"

  create_db_instance = var.response_use_rds

  identifier                = "${var.formation}-${var.formation_type}-resp"
  create_db_option_group    = false
  create_db_parameter_group = false
  engine                    = "postgres"
  engine_version            = "11.12"
  family                    = "postgres11" # DB parameter group
  major_engine_version      = "11"         # DB option group
  instance_class            = "db.t3.medium"

  allocated_storage = 32
  storage_encrypted = true
  name              = "postgres"
  username          = "postgres_admin"
  password          = aws_ssm_parameter.resp_rds_master_pass.value
  port              = 5432

  multi_az               = false
  vpc_security_group_ids = [module.registration_psql_sg.security_group_id]
  subnet_ids = module.vpc.private_subnets

  backup_retention_period = 35
  skip_final_snapshot     = true
  deletion_protection     = false
  maintenance_window      = "Mon:10:00-Mon:13:00" # In UTC time - 10 AM UTC = 3 AM PST
  backup_window           = "07:00-10:00"         # In UTC time - 7 AM UTC = midnight PST

  tags = local.additional_tags

}


# locals {
#   security_groups = local.create_sg ? [module.ssh_sg.security_group_id] : var.security_groups
# }

###############################################################################################
#
# Server EC2 instances
#
###############################################################################################

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

/*
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
*/

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


