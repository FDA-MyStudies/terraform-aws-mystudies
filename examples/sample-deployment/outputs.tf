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
  value = module.mystudies.vpc_id
}

output "vpc_arn" {
  value = module.mystudies.vpc_arn
}

output "vpc_cidr" {
  value = module.mystudies.vpc_cidr
}

output "igw_id" {
  value = module.mystudies.igw_id
}

output "vpc_alb_arn" {
  value = module.mystudies.vpc_alb_arn
}

output "base_domain" {
  value = var.base_domain
}

output "resp_db_password" {
  value     = module.mystudies.resp_db_password
  sensitive = true
}

output "resp_rds_master_pass" {
  value     = module.mystudies.resp_rds_master_pass
  sensitive = true
}

output "reg_db_password" {
  value     = module.mystudies.reg_db_password
  sensitive = true
}

output "reg_rds_master_pass" {
  value     = module.mystudies.reg_rds_master_pass
  sensitive = true
}

output "wcp_db_password" {
  value     = module.mystudies.wcp_db_password
  sensitive = true
}

output "resp_mek" {
  value     = module.mystudies.resp_mek
  sensitive = true
}

output "reg_mek" {
  value     = module.mystudies.reg_mek
  sensitive = true
}

output "resp_db_id" {
  value = module.mystudies.resp_db_id
}

output "resp_db_az" {
  value = module.mystudies.resp_db_az
}

output "resp_db_sg_id" {
  value = module.mystudies.resp_db_sg_id
}
