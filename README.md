# FDA MyStudies Terraform Module

Terraform module to create and configure the "backend" components of the FDA MyStudies platform.

<!-- markdownlint-disable -->
<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.55.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | >= 6.10.0 |
| <a name="module_bastion_ssh_sg"></a> [bastion\_ssh\_sg](#module\_bastion\_ssh\_sg) | terraform-aws-modules/security-group/aws//modules/ssh | >= 4.8.0 |
| <a name="module_common_db_subnet_group"></a> [common\_db\_subnet\_group](#module\_common\_db\_subnet\_group) | terraform-aws-modules/rds/aws//modules/db_subnet_group | >= 4.4.0 |
| <a name="module_ec2_bastion"></a> [ec2\_bastion](#module\_ec2\_bastion) | cloudposse/ec2-bastion-server/aws | 0.30.1 |
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | >= 3.14.2 |
| <a name="module_https_private_sg"></a> [https\_private\_sg](#module\_https\_private\_sg) | terraform-aws-modules/security-group/aws//modules/https-443 | >= 4.8.0 |
| <a name="module_lb_http_sg"></a> [lb\_http\_sg](#module\_lb\_http\_sg) | terraform-aws-modules/security-group/aws//modules/http-80 | >= 4.8.0 |
| <a name="module_lb_https_sg"></a> [lb\_https\_sg](#module\_lb\_https\_sg) | terraform-aws-modules/security-group/aws//modules/https-443 | >= 4.8.0 |
| <a name="module_office_ssh_sg"></a> [office\_ssh\_sg](#module\_office\_ssh\_sg) | terraform-aws-modules/security-group/aws//modules/ssh | >= 4.8.0 |
| <a name="module_registration_db"></a> [registration\_db](#module\_registration\_db) | terraform-aws-modules/rds/aws | >= 4.4.0 |
| <a name="module_registration_psql_sg"></a> [registration\_psql\_sg](#module\_registration\_psql\_sg) | terraform-aws-modules/security-group/aws//modules/postgresql | >= 4.8.0 |
| <a name="module_response_db"></a> [response\_db](#module\_response\_db) | terraform-aws-modules/rds/aws | >= 4.4.0 |
| <a name="module_response_psql_sg"></a> [response\_psql\_sg](#module\_response\_psql\_sg) | terraform-aws-modules/security-group/aws//modules/postgresql | >= 4.8.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | >= 3.14.2 |
| <a name="module_wcp_db"></a> [wcp\_db](#module\_wcp\_db) | terraform-aws-modules/rds/aws | >= 4.4.0 |
| <a name="module_wcp_mysql_sg"></a> [wcp\_mysql\_sg](#module\_wcp\_mysql\_sg) | terraform-aws-modules/security-group/aws//modules/mysql | >= 4.8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_alb_listener.alb_https_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_target_group.default_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_kms_key.mystudies_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_ssm_parameter.registration_database_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.registration_mek](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.registration_rds_master_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.response_database_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.response_mek](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.response_rds_master_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.wcp_database_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.wcp_rds_master_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.registration_database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.registration_mek](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.registration_rds_master_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.response_database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.response_mek](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.response_rds_master_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.wcp_database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.wcp_rds_master_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_route53_zone.env_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ssl_cert_arn"></a> [alb\_ssl\_cert\_arn](#input\_alb\_ssl\_cert\_arn) | ARN of existing TLS Certificate to use with ALB | `string` | n/a | yes |
| <a name="input_alb_ssl_policy"></a> [alb\_ssl\_policy](#input\_alb\_ssl\_policy) | n/a | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones in the region | `list(string)` | `[]` | no |
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | Base Domain used by applications to look-up hosted zone and make DNS records | `string` | `"lkpoc.labkey.com"` | no |
| <a name="input_bastion_enabled"></a> [bastion\_enabled](#input\_bastion\_enabled) | Set to false to prevent the module from creating bastion instance resources | `bool` | `null` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | Bastion instance type | `string` | `"t3.micro"` | no |
| <a name="input_bastion_user"></a> [bastion\_user](#input\_bastion\_user) | IAM user for logging into the bastion host | `string` | `"ec2-user"` | no |
| <a name="input_bastion_user_data"></a> [bastion\_user\_data](#input\_bastion\_user\_data) | Bastion Instance User data content | `list(string)` | `[]` | no |
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
| <a name="output_bastion_arn"></a> [bastion\_arn](#output\_bastion\_arn) | ARN of the bastion instance |
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | Disambiguated ID of the bastion instance |
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | Bastion Instance ID |
| <a name="output_bastion_name"></a> [bastion\_name](#output\_bastion\_name) | Bastion Instance name |
| <a name="output_bastion_private_dns"></a> [bastion\_private\_dns](#output\_bastion\_private\_dns) | Private DNS of bastion instance |
| <a name="output_bastion_private_ip"></a> [bastion\_private\_ip](#output\_bastion\_private\_ip) | Private IP of the bastion instance |
| <a name="output_bastion_public_dns"></a> [bastion\_public\_dns](#output\_bastion\_public\_dns) | Public DNS of bastion instance (or DNS of EIP) |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | Public IP of the bastion instance (or EIP) |
| <a name="output_bastion_role"></a> [bastion\_role](#output\_bastion\_role) | Name of AWS IAM Role associated with the instance |
| <a name="output_bastion_security_group_ids"></a> [bastion\_security\_group\_ids](#output\_bastion\_security\_group\_ids) | Bastion Security group IDs |
| <a name="output_bastion_ssh_user"></a> [bastion\_ssh\_user](#output\_bastion\_ssh\_user) | Default Username to ssh to bastion instance |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | Internet gateway ID of the deployed VPC |
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
| <a name="output_vpc_alb_arn"></a> [vpc\_alb\_arn](#output\_vpc\_alb\_arn) | ARN of the deployed Application Load Balancer |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the deployed VPC |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR of the deployed VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the deployed VPC |
| <a name="output_wcp_db_az"></a> [wcp\_db\_az](#output\_wcp\_db\_az) | n/a |
| <a name="output_wcp_db_id"></a> [wcp\_db\_id](#output\_wcp\_db\_id) | n/a |
| <a name="output_wcp_db_password"></a> [wcp\_db\_password](#output\_wcp\_db\_password) | n/a |
| <a name="output_wcp_db_sg_id"></a> [wcp\_db\_sg\_id](#output\_wcp\_db\_sg\_id) | n/a |
| <a name="output_wcp_rds_master_pass"></a> [wcp\_rds\_master\_pass](#output\_wcp\_rds\_master\_pass) | n/a |

<!--- END_TF_DOCS --->
<!-- markdownlint-restore -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.55.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | >= 4.0.1 |
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | >= 6.10.0 |
| <a name="module_appserver_ssh_sg"></a> [appserver\_ssh\_sg](#module\_appserver\_ssh\_sg) | terraform-aws-modules/security-group/aws//modules/ssh | >= 4.8.0 |
| <a name="module_bastion_ssh_sg"></a> [bastion\_ssh\_sg](#module\_bastion\_ssh\_sg) | terraform-aws-modules/security-group/aws//modules/ssh | >= 4.8.0 |
| <a name="module_common_db_subnet_group"></a> [common\_db\_subnet\_group](#module\_common\_db\_subnet\_group) | terraform-aws-modules/rds/aws//modules/db_subnet_group | >= 4.4.0 |
| <a name="module_ec2_bastion"></a> [ec2\_bastion](#module\_ec2\_bastion) | cloudposse/ec2-bastion-server/aws | 0.30.1 |
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | >= 3.14.2 |
| <a name="module_http_private_sg"></a> [http\_private\_sg](#module\_http\_private\_sg) | terraform-aws-modules/security-group/aws//modules/http-80 | >= 4.8.0 |
| <a name="module_https_private_sg"></a> [https\_private\_sg](#module\_https\_private\_sg) | terraform-aws-modules/security-group/aws//modules/https-443 | >= 4.8.0 |
| <a name="module_lb_http_sg"></a> [lb\_http\_sg](#module\_lb\_http\_sg) | terraform-aws-modules/security-group/aws//modules/http-80 | >= 4.8.0 |
| <a name="module_lb_https_sg"></a> [lb\_https\_sg](#module\_lb\_https\_sg) | terraform-aws-modules/security-group/aws//modules/https-443 | >= 4.8.0 |
| <a name="module_office_ssh_sg"></a> [office\_ssh\_sg](#module\_office\_ssh\_sg) | terraform-aws-modules/security-group/aws//modules/ssh | >= 4.8.0 |
| <a name="module_registration_db"></a> [registration\_db](#module\_registration\_db) | terraform-aws-modules/rds/aws | >= 4.4.0 |
| <a name="module_registration_psql_sg"></a> [registration\_psql\_sg](#module\_registration\_psql\_sg) | terraform-aws-modules/security-group/aws//modules/postgresql | >= 4.8.0 |
| <a name="module_response_db"></a> [response\_db](#module\_response\_db) | terraform-aws-modules/rds/aws | >= 4.4.0 |
| <a name="module_response_psql_sg"></a> [response\_psql\_sg](#module\_response\_psql\_sg) | terraform-aws-modules/security-group/aws//modules/postgresql | >= 4.8.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | >= 3.14.2 |
| <a name="module_wcp_db"></a> [wcp\_db](#module\_wcp\_db) | terraform-aws-modules/rds/aws | >= 4.4.0 |
| <a name="module_wcp_mysql_sg"></a> [wcp\_mysql\_sg](#module\_wcp\_mysql\_sg) | terraform-aws-modules/security-group/aws//modules/mysql | >= 4.8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_alb_listener.alb_https_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener_rule.resp_listener_rule_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener_rule) | resource |
| [aws_alb_target_group.default_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_alb_target_group.mystudies_response_target_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_alb_target_group_attachment.response_attachment_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group_attachment) | resource |
| [aws_ebs_volume.response_ebs_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_instance.response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_kms_key.mystudies_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb_listener_certificate.alt_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_route53_record.response_alias_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.registration_database_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.registration_mek](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.registration_rds_master_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.response_database_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.response_mek](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.response_rds_master_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.wcp_database_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.wcp_rds_master_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_volume_attachment.response_ebs_vol_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [random_password.registration_database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.registration_mek](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.registration_rds_master_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.response_database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.response_mek](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.response_rds_master_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.wcp_database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.wcp_rds_master_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_route53_zone.env_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ssl_policy"></a> [alb\_ssl\_policy](#input\_alb\_ssl\_policy) | n/a | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_alt_alb_ssl_cert_arn"></a> [alt\_alb\_ssl\_cert\_arn](#input\_alt\_alb\_ssl\_cert\_arn) | ARN of existing TLS Certificate to use with ALB | `string` | n/a | yes |
| <a name="input_appserver_private_key"></a> [appserver\_private\_key](#input\_appserver\_private\_key) | Name of private key used to ssh to appserver | `string` | `""` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones in the region | `list(string)` | `[]` | no |
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | A domain name for which the certificate should be issued | `string` | `"lkpoc.labkey.com"` | no |
| <a name="input_bastion_enabled"></a> [bastion\_enabled](#input\_bastion\_enabled) | Set to false to prevent the module from creating bastion instance resources | `bool` | `null` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | Bastion instance type | `string` | `"t3.micro"` | no |
| <a name="input_bastion_private_key"></a> [bastion\_private\_key](#input\_bastion\_private\_key) | Name of private key used to ssh to bastion server | `string` | n/a | yes |
| <a name="input_bastion_user"></a> [bastion\_user](#input\_bastion\_user) | IAM user for logging into the bastion host | `string` | `"ec2-user"` | no |
| <a name="input_bastion_user_data"></a> [bastion\_user\_data](#input\_bastion\_user\_data) | Bastion Instance User data content | `list(string)` | `[]` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Set of tags to apply to resources | `map(any)` | n/a | yes |
| <a name="input_create_certificate"></a> [create\_certificate](#input\_create\_certificate) | Whether to create ACM certificate | `bool` | `true` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | list of database subnets to use when creating vpc | `list(string)` | n/a | yes |
| <a name="input_debug"></a> [debug](#input\_debug) | whether to increase verbosity of shell scripts or not | `bool` | `false` | no |
| <a name="input_ebs_vol_type"></a> [ebs\_vol\_type](#input\_ebs\_vol\_type) | EBS data volume type - Standard, gp2, gp3, io1, io2, sc1 or sct1 | `string` | `"gp3"` | no |
| <a name="input_formation"></a> [formation](#input\_formation) | Name of VPC and associated resources, used in config paths | `any` | n/a | yes |
| <a name="input_formation_type"></a> [formation\_type](#input\_formation\_type) | production \| development | `any` | n/a | yes |
| <a name="input_install_script_repo_branch"></a> [install\_script\_repo\_branch](#input\_install\_script\_repo\_branch) | (optional) branch of install script repo to checkout | `string` | `null` | no |
| <a name="input_install_script_repo_url"></a> [install\_script\_repo\_url](#input\_install\_script\_repo\_url) | url of the install script repo | `string` | `"https://github.com/LabKey/install-script.git"` | no |
| <a name="input_office_cidr_A"></a> [office\_cidr\_A](#input\_office\_cidr\_A) | CIDR of authorized office A - used for SSM remote admin access to instances | `string` | `"199.76.89.158/32"` | no |
| <a name="input_office_cidr_B"></a> [office\_cidr\_B](#input\_office\_cidr\_B) | CIDR of authorized office B - used for SSM remote admin access to instances | `string` | `"199.76.89.152/32"` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Local path to private keys used for provisioning instances | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | list of private subnets to use when creating vpc | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | list of public subnets to use when creating vpc | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-west-2"` | no |
| <a name="input_registration_snapshot_identifier"></a> [registration\_snapshot\_identifier](#input\_registration\_snapshot\_identifier) | Snapshot Id to create Registration database from | `string` | `null` | no |
| <a name="input_registration_use_rds"></a> [registration\_use\_rds](#input\_registration\_use\_rds) | Bool to determine use of RDS for Registration Server Database | `bool` | `false` | no |
| <a name="input_response_ebs_data_snapshot_identifier"></a> [response\_ebs\_data\_snapshot\_identifier](#input\_response\_ebs\_data\_snapshot\_identifier) | Snapshot Id to create the Response Server ebs data volume from | `string` | `null` | no |
| <a name="input_response_ebs_size"></a> [response\_ebs\_size](#input\_response\_ebs\_size) | Response Server EBS data volume size | `string` | `null` | no |
| <a name="input_response_env_data"></a> [response\_env\_data](#input\_response\_env\_data) | Response Server Environment data content - used to pass in installation env settings | `map(string)` | `{}` | no |
| <a name="input_response_snapshot_identifier"></a> [response\_snapshot\_identifier](#input\_response\_snapshot\_identifier) | Snapshot Id to create Response database from | `string` | `null` | no |
| <a name="input_response_target_group_path"></a> [response\_target\_group\_path](#input\_response\_target\_group\_path) | Path used for healthcheck on Response Server | `string` | `"/"` | no |
| <a name="input_response_use_rds"></a> [response\_use\_rds](#input\_response\_use\_rds) | Bool to determine use of RDS for Response Server Database | `bool` | `false` | no |
| <a name="input_s3_state_bucket"></a> [s3\_state\_bucket](#input\_s3\_state\_bucket) | S3 bucket used to store terraform state | `string` | `""` | no |
| <a name="input_s3_state_region"></a> [s3\_state\_region](#input\_s3\_state\_region) | region of the S3 state bucket | `string` | `"us-west-2"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | list of security groups to apply | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | subnet to create instances in | `string` | `null` | no |
| <a name="input_use_common_rds_subnet_group"></a> [use\_common\_rds\_subnet\_group](#input\_use\_common\_rds\_subnet\_group) | Bool to determine use of shared RDS subnet group | `bool` | `false` | no |
| <a name="input_user"></a> [user](#input\_user) | IAM name of user who last ran this script | `string` | `""` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | cidr block for vpc | `string` | `""` | no |
| <a name="input_wcp_snapshot_identifier"></a> [wcp\_snapshot\_identifier](#input\_wcp\_snapshot\_identifier) | Snapshot Id to create WCP database from | `string` | `null` | no |
| <a name="input_wcp_use_rds"></a> [wcp\_use\_rds](#input\_wcp\_use\_rds) | Bool to determine use of RDS for WCP Server Database | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | The ARN of the certificate |
| <a name="output_acm_certificate_domain_validation_options"></a> [acm\_certificate\_domain\_validation\_options](#output\_acm\_certificate\_domain\_validation\_options) | A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used. |
| <a name="output_acm_certificate_status"></a> [acm\_certificate\_status](#output\_acm\_certificate\_status) | Status of the certificate. |
| <a name="output_base_domain"></a> [base\_domain](#output\_base\_domain) | Base internet domain used for deployment. e.g. company.com |
| <a name="output_bastion_arn"></a> [bastion\_arn](#output\_bastion\_arn) | ARN of the bastion instance |
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | Disambiguated ID of the bastion instance |
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | Bastion Instance ID |
| <a name="output_bastion_name"></a> [bastion\_name](#output\_bastion\_name) | Bastion Instance name |
| <a name="output_bastion_private_dns"></a> [bastion\_private\_dns](#output\_bastion\_private\_dns) | Private DNS of bastion instance |
| <a name="output_bastion_private_ip"></a> [bastion\_private\_ip](#output\_bastion\_private\_ip) | Private IP of the bastion instance |
| <a name="output_bastion_public_dns"></a> [bastion\_public\_dns](#output\_bastion\_public\_dns) | Public DNS of bastion instance (or DNS of EIP) |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | Public IP of the bastion instance (or EIP) |
| <a name="output_bastion_role"></a> [bastion\_role](#output\_bastion\_role) | Name of AWS IAM Role associated with the bastion instance |
| <a name="output_bastion_security_group_ids"></a> [bastion\_security\_group\_ids](#output\_bastion\_security\_group\_ids) | Bastion Security group IDs |
| <a name="output_bastion_ssh_user"></a> [bastion\_ssh\_user](#output\_bastion\_ssh\_user) | Default Username to ssh to bastion instance |
| <a name="output_distinct_domain_names"></a> [distinct\_domain\_names](#output\_distinct\_domain\_names) | List of distinct domains names used for the validation. |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | Internet gateway ID of the deployed VPC |
| <a name="output_registration_db_az"></a> [registration\_db\_az](#output\_registration\_db\_az) | Availability zone of Registration RDS database instance |
| <a name="output_registration_db_id"></a> [registration\_db\_id](#output\_registration\_db\_id) | ID of Registration RDS database instance |
| <a name="output_registration_db_password"></a> [registration\_db\_password](#output\_registration\_db\_password) | n/a |
| <a name="output_registration_db_sg_id"></a> [registration\_db\_sg\_id](#output\_registration\_db\_sg\_id) | Security group ID of Registration RDS database instance |
| <a name="output_registration_mek"></a> [registration\_mek](#output\_registration\_mek) | n/a |
| <a name="output_registration_rds_master_pass"></a> [registration\_rds\_master\_pass](#output\_registration\_rds\_master\_pass) | n/a |
| <a name="output_response_db_az"></a> [response\_db\_az](#output\_response\_db\_az) | Availability zone of Response RDS database instance |
| <a name="output_response_db_id"></a> [response\_db\_id](#output\_response\_db\_id) | ID of Response RDS database instance |
| <a name="output_response_db_password"></a> [response\_db\_password](#output\_response\_db\_password) | n/a |
| <a name="output_response_db_sg_id"></a> [response\_db\_sg\_id](#output\_response\_db\_sg\_id) | Security group ID of Response RDS database instance |
| <a name="output_response_fqdn"></a> [response\_fqdn](#output\_response\_fqdn) | Response server fully qualified domain name |
| <a name="output_response_instance_id"></a> [response\_instance\_id](#output\_response\_instance\_id) | Instance ID of the Response instance |
| <a name="output_response_mek"></a> [response\_mek](#output\_response\_mek) | n/a |
| <a name="output_response_private_ip"></a> [response\_private\_ip](#output\_response\_private\_ip) | Private IP of the Response instance |
| <a name="output_response_rds_master_pass"></a> [response\_rds\_master\_pass](#output\_response\_rds\_master\_pass) | n/a |
| <a name="output_response_url"></a> [response\_url](#output\_response\_url) | Response Server URL |
| <a name="output_validation_domains"></a> [validation\_domains](#output\_validation\_domains) | List of distinct domain validation options. This is useful if subject alternative names contain wildcards. |
| <a name="output_validation_route53_record_fqdns"></a> [validation\_route53\_record\_fqdns](#output\_validation\_route53\_record\_fqdns) | List of FQDNs built using the zone domain and name. |
| <a name="output_vpc_alb_arn"></a> [vpc\_alb\_arn](#output\_vpc\_alb\_arn) | ARN of the deployed Application Load Balancer |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the deployed VPC |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR of the deployed VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the deployed VPC |
| <a name="output_wcp_db_az"></a> [wcp\_db\_az](#output\_wcp\_db\_az) | Availability zone of WCP RDS database instance |
| <a name="output_wcp_db_id"></a> [wcp\_db\_id](#output\_wcp\_db\_id) | ID of WCP RDS database instance |
| <a name="output_wcp_db_password"></a> [wcp\_db\_password](#output\_wcp\_db\_password) | n/a |
| <a name="output_wcp_db_sg_id"></a> [wcp\_db\_sg\_id](#output\_wcp\_db\_sg\_id) | Security group ID of WCP RDS database instance |
| <a name="output_wcp_rds_master_pass"></a> [wcp\_rds\_master\_pass](#output\_wcp\_rds\_master\_pass) | n/a |
<!-- END_TF_DOCS -->