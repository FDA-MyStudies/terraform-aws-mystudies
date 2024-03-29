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


variable "debug" {
  type        = bool
  default     = false
  description = "whether to increase verbosity of shell scripts or not"
}

variable "security_group_ids" {
  type        = list(string)
  description = "list of security groups to apply"
  default     = []
}

variable "bastion_private_key" {
  type        = string
  description = "Name of private key used to ssh to bastion server"
}

variable "appserver_private_key" {
  type        = string
  default     = ""
  description = "Name of private key used to ssh to appserver"
}

variable "private_subnets" {
  type        = list(string)
  description = "list of private subnets to use when creating vpc"
}

variable "database_subnets" {
  type        = list(string)
  description = "list of database subnets to use when creating vpc"
}

variable "public_subnets" {
  type        = list(string)
  description = "list of public subnets to use when creating vpc"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "subnet to create instances in"
}

variable "private_key_path" {
  type        = string
  description = "Local path to private keys used for provisioning instances"
}

variable "install_script_repo_url" {
  type        = string
  description = "url of the install script repo"
  default     = "https://github.com/FDA-MyStudies/install-script.git"
}

variable "install_script_repo_branch" {
  type        = string
  default     = null
  description = "(optional) branch of install script repo to checkout"
}

variable "formation" {
  description = "Name of VPC and associated resources, used in config paths"
}

# might be somewhat redundant with full formation path, that's ok
variable "formation_type" {
  description = "production | development"
}

variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  type        = string
  default     = ""
  description = "cidr block for vpc"
}

variable "s3_state_bucket" {
  type        = string
  default     = ""
  description = "S3 bucket used to store terraform state"
}

variable "s3_state_region" {
  type        = string
  default     = "us-west-2"
  description = "region of the S3 state bucket"
}

variable "bastion_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating bastion instance resources"
}

variable "bastion_user" {
  description = "IAM user for logging into the bastion host"
  default     = "ec2-user"
}

variable "bastion_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Bastion instance type"
}

variable "bastion_user_data" {
  type        = list(string)
  default     = []
  description = "Bastion Instance User data content"
}

variable "user" {
  type        = string
  default     = ""
  description = "IAM name of user who last ran this script"
}

variable "office_cidr_A" {
  type        = string
  default     = "199.76.89.158/32"
  description = "CIDR of authorized office A - used for SSM remote admin access to instances"
}

variable "office_cidr_B" {
  type        = string
  default     = "199.76.89.152/32"
  description = "CIDR of authorized office B - used for SSM remote admin access to instances"
}

variable "appserver_instance_type" {
  type        = string
  default     = "t3a.large"
  description = "Ec2 Instance type used for appserver deployment"
}

variable "rds_instance_type" {
  type        = string
  default     = "db.t4g.small"
  description = "RDS Instance type used for RDS deployment"
}

# Base Domain used by applications to look-up hosted zone and make DNS records
variable "base_domain" {
  default     = "lkpoc.labkey.com" //Development domain
  description = "A domain name for which the certificate should be issued"
  type        = string
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Set of tags to apply to resources"
  type        = map(any)
}

variable "alt_alb_ssl_cert_arn" {
  type        = string
  description = "ARN of existing TLS Certificate to use with ALB"
}

variable "alb_ssl_policy" {
  # Amazon provided policies can be found:
  # http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "ebs_vol_type" {
  type        = string
  default     = "gp3"
  description = "EBS data volume type - Standard, gp2, gp3, io1, io2, sc1 or sct1"
}

variable "response_create_ec2" {
  type        = bool
  default     = true
  description = "Bool to determine if we should create Response Ec2 instance. - Used primarily for staged deployment or troubleshooting."
}

variable "response_ebs_size" {
  type        = string
  default     = null
  description = "Response Server EBS data volume size"
}

variable "response_ebs_data_snapshot_identifier" {
  type        = string
  default     = null
  description = "Snapshot Id to create the Response Server ebs data volume from"
}

variable "response_env_data" {
  type        = map(string)
  default     = {}
  description = "Response Server Environment data content - used to pass in installation env settings"
}

variable "response_target_group_path" {
  type        = string
  description = "Path used for healthcheck on Response Server"
  default     = "/"
}

variable "use_common_rds_subnet_group" {
  type        = bool
  default     = false
  description = "Bool to determine use of shared RDS subnet group "
}

variable "response_depends_on" {
  type        = any
  description = "A list of resources the Response server post_deploy depends on. e.g RDS database."
  default     = []
}

variable "response_use_rds" {
  type        = bool
  default     = false
  description = "Bool to determine use of RDS for Response Server Database"
}

variable "response_snapshot_identifier" {
  type        = string
  default     = null
  description = "Snapshot Id to create Response database from"
}

variable "registration_create_ec2" {
  type        = bool
  default     = true
  description = "Bool to determine if we should create Registration Ec2 instance. - Used primarily for staged deployment or troubleshooting."
}

variable "registration_ebs_size" {
  type        = string
  default     = null
  description = "Registration Server EBS data volume size"
}

variable "registration_ebs_data_snapshot_identifier" {
  type        = string
  default     = null
  description = "Snapshot Id to create the Registration Server ebs data volume from"
}

variable "registration_env_data" {
  type        = map(string)
  default     = {}
  description = "Registration Server Environment data content - used to pass in installation env settings"
}

variable "registration_use_rds" {
  type        = bool
  default     = false
  description = "Bool to determine use of RDS for Registration Server Database"
}

variable "registration_snapshot_identifier" {
  type        = string
  default     = null
  description = "Snapshot Id to create Registration database from"
}

variable "registration_target_group_path" {
  type        = string
  description = "Path used for healthcheck on Registration Server"
  default     = "/"
}

variable "wcp_create_ec2" {
  type        = bool
  default     = true
  description = "Bool to determine if we should create WCP Ec2 instance. - Used primarily for staged deployment or troubleshooting."
}

variable "wcp_ebs_size" {
  type        = string
  default     = null
  description = "WCP Server EBS data volume size"
}

variable "wcp_ebs_data_snapshot_identifier" {
  type        = string
  default     = null
  description = "Snapshot Id to create the WCP Server ebs data volume from"
}

variable "wcp_env_data" {
  type        = map(string)
  default     = {}
  description = "WCP Server Environment data content - used to pass in installation env settings"
}

variable "wcp_use_rds" {
  type        = bool
  default     = false
  description = "Bool to determine use of RDS for WCP Server Database"
}

variable "wcp_snapshot_identifier" {
  type        = string
  default     = null
  description = "Snapshot Id to create WCP database from"
}

variable "wcp_target_group_path" {
  type        = string
  description = "Path used for healthcheck on WCP Server"
  default     = "/"
}







