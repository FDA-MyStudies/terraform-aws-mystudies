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
  server_key         = file("${var.private_key_path}/${var.appserver_private_key}.pem")
  bastion_key        = file("${var.private_key_path}/${var.bastion_private_key}.pem")

  response_dns_shortname = "response-${local.name_prefix}"
  response_fqdn          = "${local.response_dns_shortname}.${var.base_domain}"

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




# use existing DNS Zone provided by var.base.domain
data "aws_route53_zone" "env_zone" {
  name = var.base_domain
}

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
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
  db_subnet_group_name      = module.common_db_subnet_group.db_subnet_group_id
  engine                    = "postgres"
  engine_version            = "11.12"
  family                    = "postgres11" # DB parameter group
  major_engine_version      = "11"         # DB option group
  instance_class            = "db.t3.medium"
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
  db_subnet_group_name      = module.common_db_subnet_group.db_subnet_group_id
  engine                    = "postgres"
  engine_version            = "11.12"
  family                    = "postgres11" # DB parameter group
  major_engine_version      = "11"         # DB option group
  instance_class            = "db.t3.medium"
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
  db_subnet_group_name      = module.common_db_subnet_group.db_subnet_group_id
  engine                    = "mysql"
  engine_version            = "8.0.25"
  family                    = "mysql8.0" # DB parameter group
  major_engine_version      = "8.0"      # DB option group
  instance_class            = "db.t3.medium"
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


resource "aws_instance" "response" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type
  # key_name used in ec2 console
  key_name = var.appserver_private_key

  subnet_id = module.vpc.private_subnets[0]

  # security_groups = flatten([module.alb_https_sg.this_security_group_id, module.alb_http_sg.this_security_group_id, var.security_group_ids])
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
      disable_api_termination,
      iam_instance_profile,
    ebs_optimized, ]
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

  provisioner "remote-exec" {
    inline = [
      templatefile(
        "${path.module}/install-script-warpper.tmpl",
        {
          script_name = "labkey"
          debug       = var.debug
          environment = {
            LABKEY_APP_HOME                                  = "/labkey"
            LABKEY_BASE_SERVER_URL                           = "https://${local.response_fqdn}"
            LABKEY_COMPANY_NAME                              = local.labkey_company_name
            LABKEY_DISTRIBUTION                              = "community"
            LABKEY_DIST_FILENAME                             = "LabKey22.3.4-6-community.tar.gz"
            LABKEY_DIST_URL                                  = "https://lk-binaries.s3.us-west-2.amazonaws.com/downloads/release/community/22.3.4/LabKey22.3.4-6-community.tar.gz"
            LABKEY_FILES_ROOT                                = "/labkey/labkey/files"
            LABKEY_HTTPS_PORT                                = "443"
            LABKEY_HTTP_PORT                                 = "80"
            LABKEY_INSTALL_SKIP_TOMCAT_SERVICE_EMBEDDED_STEP = "1"
            LABKEY_LOG_DIR                                   = "/labkey/apps/tomcat/logs"
            LABKEY_STARTUP_DIR                               = "/labkey/labkey/startup"
            LABKEY_SYSTEM_DESCRIPTION                        = "MyStudies Response Server"
            LABKEY_VERSION                                   = "22.3.4"
            POSTGRES_SVR_LOCAL                               = "TRUE"
            TOMCAT_INSTALL_HOME                              = "/labkey/apps/tomcat"
            TOMCAT_INSTALL_TYPE                              = "Standard"
            TOMCAT_USE_PRIVILEGED_PORTS                      = "TRUE"
          }
          url    = var.install_script_repo_url
          branch = var.install_script_repo_branch
        }
      )
    ]
  }
}

resource "aws_ebs_volume" "response_ebs_data" {
  # deploy only if response_ebs_size has a value of > Null
  count = var.response_ebs_size != "" ? 1 : 0

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
  count = var.response_ebs_size != "" ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.response_ebs_data[0].id
  instance_id = aws_instance.response.id
}

# TODO add response server dns record and outputs
# TODO consider adding NULL Resource to call a script to format and mount EBS Volume




resource "aws_alb_target_group" "mystudies_response_target_https" {
  name     = "${var.formation_type}-vpc-${var.formation}-response-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol = "HTTPS"

    //TODO make variable
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
  target_group_arn = aws_alb_target_group.mystudies_response_target_https.arn
  target_id        = aws_instance.response.id
  port             = 443
}

resource "aws_alb_listener_rule" "resp_listener_rule_https" {
  listener_arn = aws_alb_listener.alb_https_listener.arn
  depends_on   = [aws_alb_target_group.mystudies_response_target_https]
  #priority     = var.rule_priority //Required but there is no way to query for next priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mystudies_response_target_https.arn
  }

  condition {
    host_header {
      values = [local.response_fqdn]
    }
  }
}

resource "aws_route53_record" "response_alias_route" {

  zone_id = data.aws_route53_zone.env_zone.zone_id
  name    = local.response_dns_shortname
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = false
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

# TODO consider creating NULL Resource to create a ssh_config file


