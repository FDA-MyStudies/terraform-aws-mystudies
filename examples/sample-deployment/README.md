# FDA MyStudies Terraform Module

Sample deployment of this MyStudies module.

<!-- markdownlint-disable -->
<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mystudies"></a> [mystudies](#module\_mystudies) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ssl_cert_arn"></a> [alb\_ssl\_cert\_arn](#input\_alb\_ssl\_cert\_arn) | ARN of existing TLS Certificate to use with ALB | `string` | n/a | yes |
| <a name="input_alb_ssl_policy"></a> [alb\_ssl\_policy](#input\_alb\_ssl\_policy) | n/a | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones in the region | `list(string)` | `[]` | no |
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | Base Domain used by applications to look-up hosted zone and make DNS records | `string` | `"lkpoc.labkey.com"` | no |
| <a name="input_bastion_user"></a> [bastion\_user](#input\_bastion\_user) | IAM user for logging into the bastion host | `string` | `"ec2-user"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Set of tags to apply to resources | `map(any)` | n/a | yes |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | list of database subnets to use when creating vpc | `list(string)` | n/a | yes |
| <a name="input_debug"></a> [debug](#input\_debug) | whether to increase verbosity of shell scripts or not | `bool` | `false` | no |
| <a name="input_formation"></a> [formation](#input\_formation) | Name of VPC and associated resources, used in config paths | `any` | n/a | yes |
| <a name="input_formation_type"></a> [formation\_type](#input\_formation\_type) | production \| development | `any` | n/a | yes |
| <a name="input_install_script_repo_branch"></a> [install\_script\_repo\_branch](#input\_install\_script\_repo\_branch) | (optional) branch of install script repo to checkout | `string` | `null` | no |
| <a name="input_install_script_repo_url"></a> [install\_script\_repo\_url](#input\_install\_script\_repo\_url) | url of the install script repo | `string` | `"https://github.com/LabKey/install-script.git"` | no |
| <a name="input_keypair_name"></a> [keypair\_name](#input\_keypair\_name) | name of existing keypair to use when creating EC2 | `string` | n/a | yes |
| <a name="input_office_cidr_A"></a> [office\_cidr\_A](#input\_office\_cidr\_A) | CIDR of authorized office A - used for SSM remote admin access to instances | `string` | `"199.76.89.158/32"` | no |
| <a name="input_office_cidr_B"></a> [office\_cidr\_B](#input\_office\_cidr\_B) | CIDR of authorized office B - used for SSM remote admin access to instances | `string` | `"199.76.89.152/32"` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | path to the ssh private key used for provisioning instances | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | list of private subnets to use when creating vpc | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | list of public subnets to use when creating vpc | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-west-2"` | no |
| <a name="input_registration_snapshot_identifier"></a> [registration\_snapshot\_identifier](#input\_registration\_snapshot\_identifier) | Snapshot Id to create this database from | `string` | `null` | no |
| <a name="input_registration_use_rds"></a> [registration\_use\_rds](#input\_registration\_use\_rds) | Bool to determine use of RDS for Registration Server Database | `bool` | `false` | no |
| <a name="input_response_snapshot_identifier"></a> [response\_snapshot\_identifier](#input\_response\_snapshot\_identifier) | Snapshot Id to create this database from | `string` | `null` | no |
| <a name="input_response_use_rds"></a> [response\_use\_rds](#input\_response\_use\_rds) | Bool to determine use of RDS for Response Server Database | `bool` | `false` | no |
| <a name="input_s3_state_bucket"></a> [s3\_state\_bucket](#input\_s3\_state\_bucket) | S3 bucket used to store terraform state | `string` | `""` | no |
| <a name="input_s3_state_region"></a> [s3\_state\_region](#input\_s3\_state\_region) | region of the S3 state bucket | `string` | `"us-west-2"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | list of security groups to apply | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | subnet to create instances in | `string` | `null` | no |
| <a name="input_use_common_rds_subnet_group"></a> [use\_common\_rds\_subnet\_group](#input\_use\_common\_rds\_subnet\_group) | Bool to determine use of shared RDS subnet group | `bool` | `false` | no |
| <a name="input_user"></a> [user](#input\_user) | IAM name of user who last ran this script | `string` | `""` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | cidr block for vpc | `string` | `""` | no |
| <a name="input_wcp_snapshot_identifier"></a> [wcp\_snapshot\_identifier](#input\_wcp\_snapshot\_identifier) | Snapshot Id to create this database from | `string` | `null` | no |
| <a name="input_wcp_use_rds"></a> [wcp\_use\_rds](#input\_wcp\_use\_rds) | Bool to determine use of RDS for WCP Server Database | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_base_domain"></a> [base\_domain](#output\_base\_domain) | n/a |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | n/a |
| <a name="output_registration_db_az"></a> [registration\_db\_az](#output\_registration\_db\_az) | n/a |
| <a name="output_registration_db_id"></a> [registration\_db\_id](#output\_registration\_db\_id) | n/a |
| <a name="output_registration_db_password"></a> [registration\_db\_password](#output\_registration\_db\_password) | n/a |
| <a name="output_registration_db_sg_id"></a> [registration\_db\_sg\_id](#output\_registration\_db\_sg\_id) | n/a |
| <a name="output_registration_mek"></a> [registration\_mek](#output\_registration\_mek) | n/a |
| <a name="output_registration_rds_master_pass"></a> [registration\_rds\_master\_pass](#output\_registration\_rds\_master\_pass) | n/a |
| <a name="output_response_db_az"></a> [response\_db\_az](#output\_response\_db\_az) | n/a |
| <a name="output_response_db_id"></a> [response\_db\_id](#output\_response\_db\_id) | n/a |
| <a name="output_response_db_password"></a> [response\_db\_password](#output\_response\_db\_password) | n/a |
| <a name="output_response_db_sg_id"></a> [response\_db\_sg\_id](#output\_response\_db\_sg\_id) | n/a |
| <a name="output_response_mek"></a> [response\_mek](#output\_response\_mek) | n/a |
| <a name="output_response_rds_master_pass"></a> [response\_rds\_master\_pass](#output\_response\_rds\_master\_pass) | n/a |
| <a name="output_vpc_alb_arn"></a> [vpc\_alb\_arn](#output\_vpc\_alb\_arn) | n/a |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | n/a |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
| <a name="output_wcp_db_az"></a> [wcp\_db\_az](#output\_wcp\_db\_az) | n/a |
| <a name="output_wcp_db_id"></a> [wcp\_db\_id](#output\_wcp\_db\_id) | n/a |
| <a name="output_wcp_db_password"></a> [wcp\_db\_password](#output\_wcp\_db\_password) | n/a |
| <a name="output_wcp_db_sg_id"></a> [wcp\_db\_sg\_id](#output\_wcp\_db\_sg\_id) | n/a |
| <a name="output_wcp_rds_master_pass"></a> [wcp\_rds\_master\_pass](#output\_wcp\_rds\_master\_pass) | n/a |

<!--- END_TF_DOCS --->
<!-- markdownlint-restore -->
