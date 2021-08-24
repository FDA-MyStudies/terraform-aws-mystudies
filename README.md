## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_debug"></a> [debug](#input\_debug) | whether to increase verbosity of shell scripts or not | `bool` | `false` | no |
| <a name="input_install_script_repo_branch"></a> [install\_script\_repo\_branch](#input\_install\_script\_repo\_branch) | (optional) branch of install script repo to chekout | `string` | `null` | no |
| <a name="input_install_script_repo_url"></a> [install\_script\_repo\_url](#input\_install\_script\_repo\_url) | url of the install script repo | `string` | `"https://github.com/LabKey/install-script.git"` | no |
| <a name="input_keypair_name"></a> [keypair\_name](#input\_keypair\_name) | name of existing keypair to use when creating EC2 | `string` | n/a | yes |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | path to the ssh private key used for provisioning instances | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | list of security groups to apply | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | subnet to create instances in | `string` | n/a | yes |

## Outputs

No outputs.
