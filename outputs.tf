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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "vpc_alb_arn" {
  value = module.alb.lb_arn
}

output "base_domain" {
  value = var.base_domain
}

output "response_db_password" {
  value     = random_password.response_database_password.result
  sensitive = true
}

output "response_rds_master_pass" {
  value     = random_password.response_rds_master_pass.result
  sensitive = true
}

output "response_db_id" {
  value = module.response_db.db_instance_id
}

output "response_db_az" {
  value = module.response_db.db_instance_availability_zone
}

output "response_db_sg_id" {
  value = module.response_psql_sg.security_group_id
}

output "registration_db_password" {
  value     = random_password.registration_database_password.result
  sensitive = true
}

output "registration_rds_master_pass" {
  value     = random_password.registration_rds_master_pass.result
  sensitive = true
}

output "wcp_db_password" {
  value     = random_password.wcp_database_password.result
  sensitive = true
}

output "response_mek" {
  value     = random_password.response_mek.result
  sensitive = true
}

output "registration_mek" {
  value     = random_password.registration_mek.result
  sensitive = true
}
