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

output "vpc_id" {
  description = "ID of the deployed VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "ARN of the deployed VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr" {
  description = "CIDR of the deployed VPC"
  value       = module.vpc.vpc_cidr_block
}

output "igw_id" {
  description = "Internet gateway ID of the deployed VPC"
  value       = module.vpc.igw_id
}

output "vpc_alb_arn" {
  description = "ARN of the deployed Application Load Balancer"
  value       = module.alb.lb_arn
}

output "base_domain" {
  value       = var.base_domain
  description = "Base internet domain used for deployment. e.g. company.com"
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

output "acm_certificate_domain_validation_options" {
  description = "A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used."
  value       = module.acm.acm_certificate_domain_validation_options
}

output "acm_certificate_status" {
  description = "Status of the certificate."
  value       = module.acm.acm_certificate_status
}

output "validation_route53_record_fqdns" {
  description = "List of FQDNs built using the zone domain and name."
  value       = module.acm.validation_route53_record_fqdns
}

output "distinct_domain_names" {
  description = "List of distinct domains names used for the validation."
  value       = module.acm.distinct_domain_names
}

output "validation_domains" {
  description = "List of distinct domain validation options. This is useful if subject alternative names contain wildcards."
  value       = module.acm.validation_domains
}

output "bastion_instance_id" {
  value       = module.ec2_bastion.instance_id
  description = "Bastion Instance ID"
}

output "bastion_security_group_ids" {
  value       = module.ec2_bastion.security_group_ids
  description = "Bastion Security group IDs"
}

output "bastion_role" {
  value       = module.ec2_bastion.role
  description = "Name of AWS IAM Role associated with the bastion instance"
}

output "bastion_public_ip" {
  value       = module.ec2_bastion.public_ip
  description = "Public IP of the bastion instance (or EIP)"
}

output "bastion_private_ip" {
  value       = module.ec2_bastion.private_ip
  description = "Private IP of the bastion instance"
}

output "bastion_private_dns" {
  description = "Private DNS of bastion instance"
  value       = module.ec2_bastion.private_dns
}

output "bastion_public_dns" {
  description = "Public DNS of bastion instance (or DNS of EIP)"
  value       = module.ec2_bastion.public_dns
}

output "bastion_id" {
  description = "Disambiguated ID of the bastion instance"
  value       = module.ec2_bastion.id
}

output "bastion_arn" {
  description = "ARN of the bastion instance"
  value       = module.ec2_bastion.arn
}

output "bastion_name" {
  description = "Bastion Instance name"
  value       = module.ec2_bastion.name
}

output "bastion_ssh_user" {
  description = "Default Username to ssh to bastion instance"
  value       = module.ec2_bastion.ssh_user
}

output "response_db_password" {
  value     = random_password.response_database_password.result
  sensitive = true
}

output "response_fqdn" {
  value       = element(concat(aws_route53_record.response_alias_route.*.fqdn, [""]), 0)
  description = "Response server fully qualified domain name"
}

output "response_url" {
  value       = "https://${element(concat(aws_route53_record.response_alias_route.*.fqdn, [""]), 0)}"
  description = "Response Server URL"
}

output "response_private_ip" {
  value       = aws_instance.response.private_ip
  description = "Private IP of the Response instance"
}

output "response_instance_id" {
  value       = aws_instance.response.id
  description = "Instance ID of the Response instance"
}

output "response_rds_master_pass" {
  value     = random_password.response_rds_master_pass.result
  sensitive = true
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

output "response_db_id" {
  value       = module.response_db.db_instance_id
  description = "ID of Response RDS database instance"
}

output "response_db_az" {
  value       = module.response_db.db_instance_availability_zone
  description = "Availability zone of Response RDS database instance"
}

output "response_db_sg_id" {
  value       = module.response_psql_sg.security_group_id
  description = "Security group ID of Response RDS database instance"
}

output "registration_db_id" {
  value       = module.registration_db.db_instance_id
  description = "ID of Registration RDS database instance"
}

output "registration_db_az" {
  value       = module.registration_db.db_instance_availability_zone
  description = "Availability zone of Registration RDS database instance"
}

output "registration_db_sg_id" {
  value       = module.registration_psql_sg.security_group_id
  description = "Security group ID of Registration RDS database instance"
}

output "wcp_rds_master_pass" {
  value     = random_password.wcp_rds_master_pass.result
  sensitive = true
}

output "wcp_db_id" {
  value       = module.wcp_db.db_instance_id
  description = "ID of WCP RDS database instance"
}

output "wcp_db_az" {
  value       = module.wcp_db.db_instance_availability_zone
  description = "Availability zone of WCP RDS database instance"
}

output "wcp_db_sg_id" {
  value       = module.wcp_mysql_sg.security_group_id
  description = "Security group ID of WCP RDS database instance"
}
