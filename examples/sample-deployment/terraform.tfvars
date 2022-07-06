
base_domain = "dev.labkey.name"

# Set to true to create ACM TLS/TLS Cent for base_domain - Set to False to disable cert
create_certificate = true

vpc_cidr = "10.110.0.0/16"

# All AWS regions have at least 3 availability zones
azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

private_subnets = ["10.110.1.0/24", "10.110.2.0/24", "10.110.3.0/24"]

public_subnets = ["10.110.101.0/24", "10.110.102.0/24", "10.110.103.0/24"]

database_subnets = ["10.110.201.0/24", "10.110.202.0/24", "10.110.203.0/24"]

# Allows alternate or additional TLS/SSL Cert other than default OR to override default and use an existing certificate
alt_alb_ssl_cert_arn = "arn:aws:acm:us-west-2:454841571423:certificate/fdc7e2c1-8a32-4aab-99be-56081f2cd9bc"

alb_ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"

office_cidr_A = "144.202.87.91/32"

office_cidr_B = "131.226.35.101/32"

keypair_name = "4c2795d-20210823"

#private_key_path = ""

formation = "mystudies"

formation_type = "dev"

bastion_enabled = "true"

bastion_instance_type = "t3a.nano"

# Applies latest linux patches and installs ncat which is used to allow ssh through bastion instance to target instance
bastion_user_data = [
  "yum update -y && yum install -y nmap-ncat"
]


common_tags = {
  Client = "labkey"
}

s3_state_bucket = "tf.syseng.labkey.com"

s3_state_region = "us-west-2"

# Deploy Response RDS DB Instance
response_use_rds = false

# Deploy Registration RDS DB Instance
registration_use_rds = false

# Deploy WCP RDS DB Instance
wcp_use_rds = false

# Use Common RDS Subnet Group for RDS instances
use_common_rds_subnet_group = true

