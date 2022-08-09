#
# Copyright (c) 2021-2022 LabKey Corporation
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

data "aws_availability_zones" "available" {
  state = "available"
}

# use existing DNS Zone provided by var.base.domain
data "aws_route53_zone" "env_zone" {
  name = var.base_domain
}

locals {

  name_prefix        = var.formation
  name_type          = var.formation_type
  env_dns            = var.base_domain
  ssm_parameter_path = "/${var.formation}/${var.formation_type}"
  server_key         = file("${var.private_key_path}/${var.appserver_private_key}.pem")
  bastion_key        = file("${var.private_key_path}/${var.bastion_private_key}.pem")

  registration_dns_shortname = "registration-${local.name_prefix}"
  registration_fqdn          = "${local.registration_dns_shortname}.${var.base_domain}"

  response_dns_shortname = "response-${local.name_prefix}"
  response_fqdn          = "${local.response_dns_shortname}.${var.base_domain}"

  wcp_dns_shortname = "wcp-${local.name_prefix}"
  wcp_fqdn          = "${local.wcp_dns_shortname}.${var.base_domain}"

  additional_tags = merge(var.common_tags, tomap({
    Prefix      = local.name_prefix
    Environment = var.formation_type
    Formation   = var.formation
  }))

  instance_type = var.appserver_instance_type

  # If using RDS update the corresponding depends_on list to include the rds instance so appserver deployment can proceed
  # once the rds instance is deployed - otherwise Terraform would deploy appserver before RDS instance and applications would
  # fail to start.
  registration_depends_on        = [var.registration_use_rds ? module.registration_db.db_instance_id : ""]
  registration_db_host           = element([var.registration_use_rds ? module.registration_db.db_instance_address : "localhost"], 0)
  registration_db_svr_local_type = element([var.registration_use_rds ? "FALSE" : "TRUE"], 0)
  response_depends_on            = [var.response_use_rds ? module.response_db.db_instance_id : ""]
  response_db_host               = element([var.response_use_rds ? module.response_db.db_instance_address : "localhost"], 0)
  response_db_svr_local_type     = element([var.response_use_rds ? "FALSE" : "TRUE"], 0)
  wcp_depends_on                 = [var.wcp_use_rds ? module.wcp_db.db_instance_id : ""]
  wcp_db_host                    = element([var.wcp_use_rds ? module.wcp_db.db_instance_address : "localhost"], 0)
  wcp_db_svr_local_type          = element([var.wcp_use_rds ? "FALSE" : "TRUE"], 0)

  # local variable used to create administrator ssh_config file for SSH to app servers
  ssh_config = <<-EOT

Host ${module.ec2_bastion.name}
  Hostname ${module.ec2_bastion.public_dns}
  Port 22
  User ec2-user
  IdentitiesOnly Yes
  IdentityFile ${var.bastion_private_key}.pem

Host ${local.name_prefix}-registration
  Hostname ${aws_instance.registration[0].private_ip}
  Port 22
  user ubuntu
  IdentitiesOnly Yes
  IdentityFile ${var.appserver_private_key}.pem
  ProxyCommand ssh -F ssh_config.txt ${module.ec2_bastion.name} nc %h %p

Host ${local.name_prefix}-response
  Hostname ${aws_instance.response[0].private_ip}
  Port 22
  user ubuntu
  IdentitiesOnly Yes
  IdentityFile ${var.appserver_private_key}.pem
  ProxyCommand ssh -F ssh_config.txt ${module.ec2_bastion.name} nc %h %p

Host ${local.name_prefix}-wcp
  Hostname ${aws_instance.wcp[0].private_ip}
  Port 22
  user ubuntu
  IdentitiesOnly Yes
  IdentityFile ${var.appserver_private_key}.pem
  ProxyCommand ssh -F ssh_config.txt ${module.ec2_bastion.name} nc %h %p

EOT

}

###############################################################################################
#
# Networking
#
###############################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.14.2"
  # https://github.com/terraform-aws-modules/terraform-aws-vpc

  #create_vpc = var.vpc_id == null

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
  ]

  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  public_subnets   = var.public_subnets

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
  version = ">= 3.14.2"
  # https://github.com/terraform-aws-modules/terraform-aws-vpc

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

# TODO seems redundant to office_ssh_sg
module "bastion_ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

  name        = "${var.formation}-${var.formation_type}-bastion-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with SSH ports open for SSH), egress ports are all world open"

  ingress_cidr_blocks = [var.office_cidr_A, var.office_cidr_B]

  tags = local.additional_tags
}

module "lb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

  name        = "${var.formation}-${var.formation_type}-alb-http"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = local.additional_tags
}

module "lb_https_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

  name        = "${var.formation}-${var.formation_type}-alb-https"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with HTTPS ports open for everybody (IPv4 CIDR), egress ports are all world open"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = local.additional_tags
}

module "http_private_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

  name        = "${var.formation}-${var.formation_type}-private-http"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with HTTPS ports open for private VPC subnets"

  ingress_cidr_blocks = [var.vpc_cidr]

  tags = local.additional_tags
}

module "https_private_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

  name        = "${var.formation}-${var.formation_type}-private-https"
  vpc_id      = module.vpc.vpc_id
  description = "Security group with HTTPS ports open for private VPC subnets"

  ingress_cidr_blocks = [var.vpc_cidr]

  tags = local.additional_tags
}

module "office_ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

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
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

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
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

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
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

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

module "appserver_ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = ">= 4.8.0"
  # https://github.com/terraform-aws-modules/terraform-aws-security-group

  # skip creation if user has supplied own security groups list
  #create = local.create_sg

  name   = "${local.name_prefix}-appserver-ssh-sg"
  vpc_id = module.vpc.vpc_id
  #  vpc_id = var.vpc_id

  description = "Security group to allow SSH ports open for bastion/office (IPv4 CIDRs)"

  ingress_cidr_blocks = tolist([var.office_cidr_A, var.office_cidr_B, "${module.ec2_bastion.private_ip}/32"])

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-appserver-ssh-sg"
    },
  )
}





###############################################################################################
#
# Bastion Instance - used to provide ssh to instance and Terraform Remote Exec Provisioning
#
###############################################################################################

module "ec2_bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.30.1"
  # https://github.com/cloudposse/terraform-aws-ec2-bastion-server

  enabled = var.bastion_enabled


  associate_public_ip_address          = true
  instance_type                        = var.bastion_instance_type
  key_name                             = var.bastion_private_key
  metadata_http_endpoint_enabled       = true
  metadata_http_put_response_hop_limit = 1
  metadata_http_tokens_required        = true
  name                                 = "JUMPBOX"
  namespace                            = var.formation
  security_group_enabled               = false
  security_groups                      = [module.bastion_ssh_sg.security_group_id]
  ssh_user                             = var.bastion_user
  subnets                              = module.vpc.public_subnets
  tags                                 = local.additional_tags
  user_data                            = var.bastion_user_data
  vpc_id                               = module.vpc.vpc_id


}
###############################################################################################



###############################################################################################
#
# ACM - TLS Certificate
#
###############################################################################################

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = ">= 4.0.1"

  create_certificate = var.create_certificate
  domain_name        = "*.${local.env_dns}"
  zone_id            = data.aws_route53_zone.env_zone.id

  validation_method    = "DNS"
  validate_certificate = true
  wait_for_validation  = true

  subject_alternative_names = var.formation_type == "prod" ? ["*.${var.base_domain}"] : []

  tags = local.additional_tags
}
###############################################################################################


###############################################################################################
#
# ALB - Application Load Balancer
#
###############################################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = ">= 6.10.0"
  # https://github.com/terraform-aws-modules/terraform-aws-alb

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

  drop_invalid_header_fields = true
  tags                       = local.additional_tags
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
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.default_target.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "alt_cert" {
  count           = var.alt_alb_ssl_cert_arn != "" ? 1 : 0
  depends_on      = [aws_alb_target_group.default_target]
  listener_arn    = aws_alb_listener.alb_https_listener.arn
  certificate_arn = var.alt_alb_ssl_cert_arn
}
###############################################################################################


###############################################################################################
#
# Secrets Management
#
###############################################################################################

resource "aws_kms_key" "mystudies_kms_key" {
  description             = "KMS Encryption Key Used for Secrets Management"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.additional_tags
}

resource "random_password" "response_database_password" {
  length           = 32
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  special          = true
  override_special = "!#*-_=+[].,:?"
}

resource "aws_ssm_parameter" "response_database_password" {
  name   = "${local.ssm_parameter_path}/db/resp_db_password"
  type   = "SecureString"
  value  = random_password.response_database_password.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags
}

resource "random_password" "response_rds_master_pass" {
  length           = 32
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  special          = true
  override_special = "!#*-_=+[].,:?"
}

resource "aws_ssm_parameter" "response_rds_master_pass" {
  name   = "${local.ssm_parameter_path}/db/resp_rds_master_pass"
  type   = "SecureString"
  value  = random_password.response_rds_master_pass.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags
}



# Generate Response LabKey Main Encryption Key (MEK)
resource "random_password" "response_mek" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  special     = false
}

resource "aws_ssm_parameter" "response_mek" {
  name   = "${local.ssm_parameter_path}/mek/resp_mek"
  type   = "SecureString"
  value  = random_password.response_mek.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags
}

resource "random_password" "registration_rds_master_pass" {
  length           = 32
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  special          = true
  override_special = "!#*-_=+[].,:?"
}

resource "aws_ssm_parameter" "registration_rds_master_pass" {
  name   = "${local.ssm_parameter_path}/db/reg_rds_master_pass"
  type   = "SecureString"
  value  = random_password.registration_rds_master_pass.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags
}

resource "random_password" "registration_database_password" {
  length           = 32
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  special          = true
  override_special = "!#*-_=+[].,:?"
}

resource "aws_ssm_parameter" "registration_database_password" {
  name   = "${local.ssm_parameter_path}/db/reg_db_password"
  type   = "SecureString"
  value  = random_password.registration_database_password.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags
}

# Generate Registration LabKey Main Encryption Key (MEK)
resource "random_password" "registration_mek" {
  length      = 32
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
  special     = false
}

resource "aws_ssm_parameter" "registration_mek" {
  name   = "${local.ssm_parameter_path}/mek/reg_mek"
  type   = "SecureString"
  value  = random_password.registration_mek.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags
}


# Mysql max password length is 32
resource "random_password" "wcp_database_password" {
  length           = 30
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  special          = true
  override_special = "!#*-_=+[].,:?"
}

resource "aws_ssm_parameter" "wcp_database_password" {
  name   = "${local.ssm_parameter_path}/db/wcp_db_password"
  type   = "SecureString"
  value  = random_password.wcp_database_password.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags
}

resource "random_password" "wcp_rds_master_pass" {
  length           = 32
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  special          = true
  override_special = "!#*-_=+[].,:?"
}

resource "aws_ssm_parameter" "wcp_rds_master_pass" {
  name   = "${local.ssm_parameter_path}/db/wcp_rds_master_pass"
  type   = "SecureString"
  value  = random_password.wcp_rds_master_pass.result
  key_id = aws_kms_key.mystudies_kms_key.id
  tags   = local.additional_tags

}
###############################################################################################


###############################################################################################
#
# RDS Deployments
#
###############################################################################################

module "common_db_subnet_group" {
  source  = "terraform-aws-modules/rds/aws//modules/db_subnet_group"
  version = ">= 4.4.0"
  # https://github.com/terraform-aws-modules/terraform-aws-rds

  create      = var.use_common_rds_subnet_group
  name        = "${local.name_prefix}-db-common"
  description = "${local.name_prefix} common db subnet group"
  subnet_ids  = module.vpc.database_subnets

  tags = local.additional_tags
}


# Response Server RDS Database Instance
module "response_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = ">= 4.4.0"
  # https://github.com/terraform-aws-modules/terraform-aws-rds

  create_db_instance = var.response_use_rds

  identifier                = "${var.formation}-${var.formation_type}-response"
  create_db_option_group    = false
  create_db_parameter_group = false
  create_db_subnet_group    = false
  create_random_password    = false # required when you provide your own password
  db_subnet_group_name      = module.common_db_subnet_group.db_subnet_group_id
  engine                    = "postgres"
  engine_version            = "12.11"
  family                    = "postgres12" # DB parameter group
  major_engine_version      = "12"         # DB option group
  instance_class            = var.rds_instance_type
  snapshot_identifier       = var.response_snapshot_identifier

  allocated_storage = 32
  storage_encrypted = true
  db_name           = "postgres"
  username          = "postgres_admin"
  password          = aws_ssm_parameter.response_rds_master_pass.value
  port              = 5432

  multi_az               = false
  vpc_security_group_ids = [module.response_psql_sg.security_group_id]
  subnet_ids             = module.vpc.database_subnets

  backup_retention_period = 35
  skip_final_snapshot     = true
  deletion_protection     = false
  maintenance_window      = "Mon:10:00-Mon:13:00" # In UTC time - 10 AM UTC = 3 AM PST
  backup_window           = "07:00-10:00"         # In UTC time - 7 AM UTC = midnight PST

  tags = local.additional_tags

}


# Registration Server RDS Database Instance
module "registration_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = ">= 4.4.0"
  # https://github.com/terraform-aws-modules/terraform-aws-rds

  create_db_instance = var.registration_use_rds

  identifier                = "${var.formation}-${var.formation_type}-registration"
  create_db_option_group    = false
  create_db_parameter_group = false
  create_db_subnet_group    = false
  create_random_password    = false # required when you provide your own password
  db_subnet_group_name      = module.common_db_subnet_group.db_subnet_group_id
  engine                    = "postgres"
  engine_version            = "12.11"
  family                    = "postgres12" # DB parameter group
  major_engine_version      = "12"         # DB option group
  instance_class            = var.rds_instance_type
  snapshot_identifier       = var.registration_snapshot_identifier

  allocated_storage = 32
  storage_encrypted = true
  db_name           = "postgres"
  username          = "postgres_admin"
  password          = aws_ssm_parameter.registration_rds_master_pass.value
  port              = 5432

  multi_az               = false
  vpc_security_group_ids = [module.registration_psql_sg.security_group_id]
  subnet_ids             = module.vpc.database_subnets

  backup_retention_period = 35
  skip_final_snapshot     = true
  deletion_protection     = false
  copy_tags_to_snapshot   = true
  maintenance_window      = "Mon:10:00-Mon:13:00" # In UTC time - 10 AM UTC = 3 AM PST
  backup_window           = "07:00-10:00"         # In UTC time - 7 AM UTC = midnight PST

  tags = local.additional_tags

}

# WCP Server RDS Database Instance
module "wcp_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = ">= 4.4.0"
  # https://github.com/terraform-aws-modules/terraform-aws-rds

  create_db_instance = var.wcp_use_rds

  identifier                = "${var.formation}-${var.formation_type}-wcp"
  create_db_option_group    = false
  create_db_parameter_group = false
  create_db_subnet_group    = false
  create_random_password    = false # required when you provide your own password
  db_subnet_group_name      = module.common_db_subnet_group.db_subnet_group_id
  engine                    = "mysql"
  engine_version            = "8.0.28"
  family                    = "mysql8.0" # DB parameter group
  major_engine_version      = "8.0"      # DB option group
  instance_class            = var.rds_instance_type
  snapshot_identifier       = var.wcp_snapshot_identifier

  allocated_storage = 32
  storage_encrypted = true
  db_name           = "wcp"
  username          = "mysql_admin"
  password          = aws_ssm_parameter.wcp_rds_master_pass.value
  port              = 3306

  multi_az               = false
  vpc_security_group_ids = [module.wcp_mysql_sg.security_group_id]
  subnet_ids             = module.vpc.database_subnets

  backup_retention_period = 35
  skip_final_snapshot     = true
  deletion_protection     = false
  copy_tags_to_snapshot   = true
  maintenance_window      = "Mon:10:00-Mon:13:00" # In UTC time - 10 AM UTC = 3 AM PST
  backup_window           = "07:00-10:00"         # In UTC time - 7 AM UTC = midnight PST

  tags = local.additional_tags

}


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

# SSH Config file to be used for SSH to app servers - defaults current path - e.g. ./examples/sample-deployment
resource "local_file" "ssh_config" {
  filename = "./ssh_config.txt"
  content  = local.ssh_config
}


########################
# Registration Instance
########################

resource "aws_instance" "registration" {
  count         = var.registration_create_ec2 ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type
  # key_name used in ec2 console
  key_name = var.appserver_private_key

  subnet_id = module.vpc.private_subnets[0]

  vpc_security_group_ids = compact([module.appserver_ssh_sg.security_group_id, module.https_private_sg.security_group_id])

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-registration"
    },
  )

  volume_tags = merge(
    local.additional_tags,
    {
      "Name" = "${local.name_prefix}-registration-volume"
    },
  )

  lifecycle {
    ignore_changes = [
      tags,
      volume_tags,
      disable_api_termination,
      iam_instance_profile,
      ebs_optimized
    ]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    # local file path to private key
    private_key = local.server_key

    host = coalesce(self.public_ip, self.private_ip)

    bastion_host        = module.ec2_bastion.public_dns
    bastion_user        = module.ec2_bastion.ssh_user
    bastion_private_key = local.bastion_key
  }
}

resource "aws_ebs_volume" "registration_ebs_data" {
  count = var.registration_create_ec2 && var.registration_ebs_size != "" ? 1 : 0

  availability_zone = data.aws_availability_zones.available.names[0]
  size              = var.registration_ebs_size
  encrypted         = true
  snapshot_id       = var.registration_ebs_data_snapshot_identifier
  type              = var.ebs_vol_type
  tags = merge(
    local.additional_tags,
    {
      "Name" = "${local.name_prefix}-registration-data-volume"
    },
  )
}

resource "aws_volume_attachment" "registration_ebs_vol_attachment" {
  count = var.registration_create_ec2 && var.registration_ebs_size != "" ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.registration_ebs_data[0].id
  instance_id = aws_instance.registration[0].id
}

resource "null_resource" "registration_post_deploy_provisioner" {
  count      = var.registration_create_ec2 ? 1 : 0
  depends_on = [local.registration_depends_on]
  triggers = {
    appserver = aws_instance.registration[0].id
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    # local file path to private key
    private_key = local.server_key

    host = aws_instance.registration[0].private_ip

    bastion_host        = module.ec2_bastion.public_dns
    bastion_user        = module.ec2_bastion.ssh_user
    bastion_private_key = local.bastion_key
  }

  provisioner "remote-exec" {
    inline = [
      templatefile(
        "${path.module}/install-script-wrapper.tmpl",
        {
          script_name = "labkey"
          debug       = var.debug
          # merge user defined registration env with fixed values
          environment = merge(var.registration_env_data,
            {
              LABKEY_APP_HOME                                  = "/labkey"
              LABKEY_BASE_SERVER_URL                           = "https://${local.registration_fqdn}"
              LABKEY_FILES_ROOT                                = "/labkey/labkey/files"
              LABKEY_HTTPS_PORT                                = "443"
              LABKEY_HTTP_PORT                                 = "80"
              LABKEY_INSTALL_SKIP_TOMCAT_SERVICE_EMBEDDED_STEP = "1"
              LABKEY_LOG_DIR                                   = "/labkey/apps/tomcat/logs"
              LABKEY_STARTUP_DIR                               = "/labkey/labkey/startup"
              POSTGRES_HOST                                    = local.registration_db_host
              POSTGRES_PASSWORD                                = nonsensitive(aws_ssm_parameter.registration_database_password.value)
              POSTGRES_REMOTE_ADMIN_PASSWORD                   = nonsensitive(aws_ssm_parameter.registration_rds_master_pass.value)
              POSTGRES_REMOTE_ADMIN_USER                       = "postgres_admin"
              POSTGRES_SVR_LOCAL                               = local.registration_db_svr_local_type
              TOMCAT_INSTALL_HOME                              = "/labkey/apps/tomcat"
              TOMCAT_INSTALL_TYPE                              = "Standard"
              TOMCAT_USE_PRIVILEGED_PORTS                      = "TRUE"
            }
          )
          url    = var.install_script_repo_url
          branch = var.install_script_repo_branch
        }
      )
    ]
  }

}

resource "aws_alb_target_group" "mystudies_registration_target_https" {
  count    = var.registration_create_ec2 ? 1 : 0
  name     = "${var.formation_type}-vpc-${var.formation}-reg-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol = "HTTPS"

    healthy_threshold   = 2
    interval            = 15
    path                = var.registration_target_group_path
    matcher             = "200,302"
    timeout             = 5
    unhealthy_threshold = 5
  }

  tags = local.additional_tags
}

resource "aws_alb_target_group_attachment" "registration_attachment_https" {
  count            = var.registration_create_ec2 ? 1 : 0
  target_group_arn = aws_alb_target_group.mystudies_registration_target_https[0].arn
  target_id        = aws_instance.registration[0].id
  port             = 443
}

resource "aws_alb_listener_rule" "reg_listener_rule_https" {
  count        = var.registration_create_ec2 ? 1 : 0
  listener_arn = aws_alb_listener.alb_https_listener.arn
  depends_on   = [aws_alb_target_group.mystudies_registration_target_https]
  #priority     = var.rule_priority //Required but there is no way to query for next priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mystudies_registration_target_https[0].arn
  }

  condition {
    host_header {
      values = [local.registration_fqdn]
    }
  }
}

resource "aws_route53_record" "registration_alias_route" {
  count   = var.registration_create_ec2 ? 1 : 0
  zone_id = data.aws_route53_zone.env_zone.zone_id
  name    = local.registration_dns_shortname
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = false
  }
}

# ---- End Registration Server Settings --------------------------------------------------------------------------------

########################
# Response Instance
########################


resource "aws_instance" "response" {

  count         = var.response_create_ec2 ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type
  # key_name used in ec2 console
  key_name = var.appserver_private_key

  subnet_id = module.vpc.private_subnets[0]

  vpc_security_group_ids = compact([module.appserver_ssh_sg.security_group_id, module.https_private_sg.security_group_id])

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-response"
    },
  )

  volume_tags = merge(
    local.additional_tags,
    {
      "Name" = "${local.name_prefix}-response-volume"
    },
  )

  lifecycle {
    ignore_changes = [
      tags,
      volume_tags,
      disable_api_termination,
      iam_instance_profile,
      ebs_optimized
    ]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    # local file path to private key
    private_key = local.server_key

    host = coalesce(self.public_ip, self.private_ip)

    bastion_host        = module.ec2_bastion.public_dns
    bastion_user        = module.ec2_bastion.ssh_user
    bastion_private_key = local.bastion_key
  }
}

resource "aws_ebs_volume" "response_ebs_data" {
  count = var.response_create_ec2 && var.response_ebs_size != "" ? 1 : 0

  availability_zone = data.aws_availability_zones.available.names[0]
  size              = var.response_ebs_size
  encrypted         = true
  snapshot_id       = var.response_ebs_data_snapshot_identifier
  type              = var.ebs_vol_type
  tags = merge(
    local.additional_tags,
    {
      "Name" = "${local.name_prefix}-response-data-volume"
    },
  )
}

resource "aws_volume_attachment" "response_ebs_vol_attachment" {
  count = var.response_create_ec2 && var.response_ebs_size != "" ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.response_ebs_data[0].id
  instance_id = aws_instance.response[0].id
}

#

resource "null_resource" "response_post_deploy_provisioner" {
  count      = var.response_create_ec2 ? 1 : 0
  depends_on = [local.response_depends_on]
  triggers = {
    appserver = aws_instance.response[0].id
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    # local file path to private key
    private_key = local.server_key

    host = aws_instance.response[0].private_ip

    bastion_host        = module.ec2_bastion.public_dns
    bastion_user        = module.ec2_bastion.ssh_user
    bastion_private_key = local.bastion_key
  }

  provisioner "remote-exec" {
    inline = [
      templatefile(
        "${path.module}/install-script-wrapper.tmpl",
        {
          script_name = "labkey"
          debug       = var.debug
          # merge user defined response env with fixed values
          environment = merge(var.response_env_data,
            {
              LABKEY_APP_HOME                                  = "/labkey"
              LABKEY_BASE_SERVER_URL                           = "https://${local.response_fqdn}"
              LABKEY_FILES_ROOT                                = "/labkey/labkey/files"
              LABKEY_HTTPS_PORT                                = "443"
              LABKEY_HTTP_PORT                                 = "80"
              LABKEY_INSTALL_SKIP_TOMCAT_SERVICE_EMBEDDED_STEP = "1"
              LABKEY_LOG_DIR                                   = "/labkey/apps/tomcat/logs"
              LABKEY_STARTUP_DIR                               = "/labkey/labkey/startup"
              LABKEY_STARTUP_DIR                               = "/labkey/labkey/startup"
              POSTGRES_HOST                                    = local.response_db_host
              POSTGRES_PASSWORD                                = nonsensitive(aws_ssm_parameter.response_database_password.value)
              POSTGRES_REMOTE_ADMIN_PASSWORD                   = nonsensitive(aws_ssm_parameter.response_rds_master_pass.value)
              POSTGRES_REMOTE_ADMIN_USER                       = "postgres_admin"
              POSTGRES_SVR_LOCAL                               = local.response_db_svr_local_type
              TOMCAT_INSTALL_HOME                              = "/labkey/apps/tomcat"
              TOMCAT_INSTALL_TYPE                              = "Standard"
              TOMCAT_USE_PRIVILEGED_PORTS                      = "TRUE"
            }
          )
          url    = var.install_script_repo_url
          branch = var.install_script_repo_branch
        }
      )
    ]
  }

}


resource "aws_alb_target_group" "mystudies_response_target_https" {
  count    = var.response_create_ec2 ? 1 : 0
  name     = "${var.formation_type}-vpc-${var.formation}-response-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol = "HTTPS"

    healthy_threshold   = 2
    interval            = 15
    path                = var.response_target_group_path
    matcher             = "200,302"
    timeout             = 5
    unhealthy_threshold = 5
  }

  tags = local.additional_tags
}

resource "aws_alb_target_group_attachment" "response_attachment_https" {
  count            = var.response_create_ec2 ? 1 : 0
  target_group_arn = aws_alb_target_group.mystudies_response_target_https[0].arn
  target_id        = aws_instance.response[0].id
  port             = 443
}

resource "aws_alb_listener_rule" "resp_listener_rule_https" {
  count        = var.response_create_ec2 ? 1 : 0
  listener_arn = aws_alb_listener.alb_https_listener.arn
  depends_on   = [aws_alb_target_group.mystudies_response_target_https]
  #priority     = var.rule_priority //Required but there is no way to query for next priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mystudies_response_target_https[0].arn
  }

  condition {
    host_header {
      values = [local.response_fqdn]
    }
  }
}

resource "aws_route53_record" "response_alias_route" {
  count   = var.response_create_ec2 ? 1 : 0
  zone_id = data.aws_route53_zone.env_zone.zone_id
  name    = local.response_dns_shortname
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = false
  }
}
# ---- End Response Server Config---------------------------------------------------------------------------------------


########################
# WCP Instance
########################

resource "aws_instance" "wcp" {

  count         = var.wcp_create_ec2 ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type
  # key_name used in ec2 console
  key_name = var.appserver_private_key

  subnet_id = module.vpc.private_subnets[0]

  vpc_security_group_ids = compact([module.appserver_ssh_sg.security_group_id, module.https_private_sg.security_group_id])

  tags = merge(
    local.additional_tags,
    {
      Name = "${local.name_prefix}-wcp"
    },
  )

  volume_tags = merge(
    local.additional_tags,
    {
      "Name" = "${local.name_prefix}-wcp-volume"
    },
  )

  lifecycle {
    ignore_changes = [
      tags,
      volume_tags,
      disable_api_termination,
      iam_instance_profile,
      ebs_optimized
    ]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    # local file path to private key
    private_key = local.server_key

    host = coalesce(self.public_ip, self.private_ip)

    bastion_host        = module.ec2_bastion.public_dns
    bastion_user        = module.ec2_bastion.ssh_user
    bastion_private_key = local.bastion_key
  }
}

resource "aws_ebs_volume" "wcp_ebs_data" {
  count = var.wcp_create_ec2 && var.wcp_ebs_size != "" ? 1 : 0

  availability_zone = data.aws_availability_zones.available.names[0]
  size              = var.wcp_ebs_size
  encrypted         = true
  snapshot_id       = var.wcp_ebs_data_snapshot_identifier
  type              = var.ebs_vol_type
  tags = merge(
    local.additional_tags,
    {
      "Name" = "${local.name_prefix}-wcp-data-volume"
    },
  )
}

resource "aws_volume_attachment" "wcp_ebs_vol_attachment" {
  count = var.wcp_create_ec2 && var.wcp_ebs_size != "" ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.wcp_ebs_data[0].id
  instance_id = aws_instance.wcp[0].id
}

#

resource "null_resource" "wcp_post_deploy_provisioner" {
  count      = var.wcp_create_ec2 ? 1 : 0
  depends_on = [local.wcp_depends_on]
  triggers = {
    appserver = aws_instance.wcp[0].id
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    # local file path to private key
    private_key = local.server_key

    host = aws_instance.wcp[0].private_ip

    bastion_host        = module.ec2_bastion.public_dns
    bastion_user        = module.ec2_bastion.ssh_user
    bastion_private_key = local.bastion_key
  }

  provisioner "remote-exec" {
    inline = [
      templatefile(
        "${path.module}/install-script-wrapper.tmpl",
        {
          script_name = "wcp"
          debug       = var.debug
          # merge user defined wcp env with fixed values
          environment = merge(var.wcp_env_data,
            {
              LABKEY_APP_HOME                                  = "/labkey"
              LABKEY_BASE_SERVER_URL                           = "https://${local.wcp_fqdn}"
              LABKEY_CONFIG_DIR                                = "/labkey/apps/tomcat/conf"
              LABKEY_FILES_ROOT                                = "/labkey/labkey/files"
              LABKEY_HTTPS_PORT                                = "443"
              LABKEY_HTTP_PORT                                 = "80"
              LABKEY_INSTALL_SKIP_MAIN                         = "1"
              LABKEY_INSTALL_SKIP_TOMCAT_SERVICE_EMBEDDED_STEP = "1"
              LABKEY_LOG_DIR                                   = "/labkey/apps/tomcat/logs"
              LABKEY_STARTUP_DIR                               = "/labkey/labkey/startup"
              MYSQL_HOST                                       = local.wcp_db_host
              MYSQL_PASSWORD                                   = nonsensitive(aws_ssm_parameter.wcp_database_password.value)
              MYSQL_PROVISION_REMOTE_DB                        = "TRUE"
              MYSQL_REMOTE_ADMIN_USER                          = "mysql_admin"
              MYSQL_REMOTE_ADMIN_PASSWORD                      = nonsensitive(aws_ssm_parameter.wcp_rds_master_pass.value)
              MYSQL_ROOT_PASSWORD                              = nonsensitive(aws_ssm_parameter.wcp_rds_master_pass.value)
              MYSQL_SVR_LOCAL                                  = local.wcp_db_svr_local_type
              SMTP_HOST                                        = "localhost"
              SMTP_PORT                                        = "25"
              TOMCAT_INSTALL_HOME                              = "/labkey/apps/tomcat"
              TOMCAT_INSTALL_TYPE                              = "Standard"
              TOMCAT_TMP_DIR                                   = "/labkey/tomcat-tmp"
              TOMCAT_USE_PRIVILEGED_PORTS                      = "TRUE"
              WCP_HOSTNAME                                     = "https://${element(concat(aws_route53_record.wcp_alias_route.*.fqdn, [""]), 0)}"
              WCP_REGISTRATION_URL                             = "https://${element(concat(aws_route53_record.registration_alias_route.*.fqdn, [""]), 0)}"
              WCP_APP_ENV                                      = var.formation_type
            }
          )
          url    = var.install_script_repo_url
          branch = var.install_script_repo_branch
        }
      )
    ]
  }

}


resource "aws_alb_target_group" "mystudies_wcp_target_https" {
  count    = var.wcp_create_ec2 ? 1 : 0
  name     = "${var.formation_type}-vpc-${var.formation}-wcp-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol = "HTTPS"

    healthy_threshold   = 2
    interval            = 15
    path                = var.wcp_target_group_path
    matcher             = "200,302"
    timeout             = 5
    unhealthy_threshold = 5
  }

  tags = local.additional_tags
}

resource "aws_alb_target_group_attachment" "wcp_attachment_https" {
  count            = var.wcp_create_ec2 ? 1 : 0
  target_group_arn = aws_alb_target_group.mystudies_wcp_target_https[0].arn
  target_id        = aws_instance.wcp[0].id
  port             = 443
}

resource "aws_alb_listener_rule" "wcp_listener_rule_https" {
  count        = var.wcp_create_ec2 ? 1 : 0
  listener_arn = aws_alb_listener.alb_https_listener.arn
  depends_on   = [aws_alb_target_group.mystudies_wcp_target_https]
  #priority     = var.rule_priority //Required but there is no way to query for next priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mystudies_wcp_target_https[0].arn
  }

  condition {
    host_header {
      values = [local.wcp_fqdn]
    }
  }
}

resource "aws_route53_record" "wcp_alias_route" {
  count   = var.wcp_create_ec2 ? 1 : 0
  zone_id = data.aws_route53_zone.env_zone.zone_id
  name    = local.wcp_dns_shortname
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = false
  }
}

# ---- End WCP Server Config--------------------------------------------------------------------------------------------

#
