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

variable "debug" {
  type        = bool
  default     = false
  description = "whether to increase verbosity of shell scripts or not"
}

variable "ami" {
  type        = string
  description = "AMI to use for instances, defaults to latest ubuntu"
  default     = null
}

variable "keypair_name" {
  type        = string
  description = "name of existing keypair to use when creating EC2"
}

variable "private_key_path" {
  type        = string
  description = "path to the ssh private key used for provisioning instances"
}

variable "install_script_repo_url" {
  type        = string
  description = "url of the install script repo"
  default     = "https://github.com/LabKey/install-script.git"
}

variable "install_script_repo_branch" {
  type        = string
  default     = null
  description = "branch of install script repo to checkout, default: develop"
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type to use"
  default     = "t3a.large"
}

variable "subnet_id" {
  type        = string
  description = "subnet to create instances in"
}

variable "formation" {
  type        = string
  description = "arbitrary string used when naming resources"
  default     = "mystudies"
}

variable "base_domain" {
  type        = string
  description = "basis for the subdomains of instances"
}

variable "common_tags" {
  description = "Set of tags to apply to resources"
  type        = map(any)
  default     = {}
}

variable "security_group_ids" {
  type        = list(string)
  description = "list of security groups to apply"
}

# variable "vpc_id" {
#   type        = string
#   default     = null
#   description = "id of the vpc within which to create the infrastructure"
# }

# variable "private_subnets" {
#   type        = list(string)
#   description = "list of private subnets to use when creating vpc"
# }

# variable "public_subnets" {
#   type        = list(string)
#   description = "list of public subnets to use when creating vpc"
# }



# /*
#  variable "private_subnet_ids" {
#    type        = list(string)
#    description = "list of private subnet ids to use when creating vpc"
# }

#  variable "public_subnet_ids" {
#    type        = list(string)
#    description = "list of public subnet ids to use when creating vpc"
# }
# */

# variable "azs" {
#   description = "A list of availability zones in the region"
#   type        = list(string)
#   default     = []
# }

# # might be somewhat redundant with full formation path, that's ok
# variable "formation_type" {
#   description = "production | development"
# }

# variable "region" {
#   default = "us-west-2"
# }

# variable "vpc_cidr" {
#   type        = string
#   default     = ""
#   description = "cidr block for vpc"
# }

# variable "s3_state_bucket" {
#   type        = string
#   default     = ""
#   description = "S3 bucket used to store terraform state"
# }

# variable "s3_state_region" {
#   type        = string
#   default     = "us-west-2"
#   description = "region of the S3 state bucket"
# }

# variable "bastion_user" {
#   description = "IAM user for logging into the bastion host"
#   default     = "ec2-user"
# }

# variable "user" {
#   type        = string
#   default     = ""
#   description = "IAM name of user who last ran this script"
# }

# variable "office_cidr_A" {
#   type        = string
#   default     = "199.76.89.158/32"
#   description = "CIDR of authorized office A - used for SSM remote admin access to instances"
# }

# variable "office_cidr_B" {
#   type        = string
#   default     = "199.76.89.152/32"
#   description = "CIDR of authorized office B - used for SSM remote admin access to instances"
# }



# // Base Domain used by applications to look-up hosted zone and make DNS records
# variable "base_domain" {
#   default = "lkpoc.labkey.com" //Development domain
# }

# variable "alb_ssl_cert_arn" {
#   type        = string
#   description = "ARN of existing TLS Certificate to use with ALB "
# }

# variable "alb_ssl_policy" {
#   # Amazon provided policies can be found:
#   # http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html
#   default = "ELBSecurityPolicy-TLS-1-2-2017-01"
# }







