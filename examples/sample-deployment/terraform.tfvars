
debug = false

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

appserver_instance_type = "t3a.large"

appserver_private_key = "4c2795d-20210823"

bastion_private_key = "4c2795d-20210823"

private_key_path = "~/.keys/syseng-dev"

formation = "mystudies"

formation_type = "dev"

bastion_instance_type = "t3a.nano"

rds_instance_type = "db.t4g.small"

# Bastion initial startup tasks - Applies latest linux patches and installs ncat which is used to allow ssh through bastion instance to target instance
bastion_user_data = [
  "yum update -y && yum install -y nmap-ncat"
]

# Tags included in all resources
common_tags = {
  Client = "labkey"
}

# Use Common RDS Subnet Group for RDS instances
use_common_rds_subnet_group = true

#
# ---- Registration Server Settings -----------------------------------------------------------------------------------
#

# Deploy Registration EC2 Instance
registration_create_ec2 = true

# Deploy Registration RDS DB Instance
registration_use_rds = true

# Set to null to disable registration server ebs data volume - otherwise enter a value in GB
registration_ebs_size = "16"

# Snapshot ID used as source for registration ebs data volume - Null = empty volume
registration_ebs_data_snapshot_identifier = ""

registration_env_data = {
  LABKEY_COMPANY_NAME          = "LabKey"
  LABKEY_DISTRIBUTION          = "community"
  LABKEY_DIST_FILENAME         = "LabKey22.7.1-1-Registration.tar.gz"
  LABKEY_DIST_URL              = "https://lk-binaries.s3-us-west-2.amazonaws.com/downloads/release/Registration/22.7.1/LabKey22.7.1-1-Registration.tar.gz"
  LABKEY_SYSTEM_DESCRIPTION    = "MyStudies Registration Server"
  LABKEY_VERSION               = "22.7.1"
  POSTGRES_PROVISION_REMOTE_DB = "TRUE"
  TOMCAT_VERSION               = "9.0.65"
}

#
# ---- Response Server Settings ---------------------------------------------------------------------------------------
#

# Deploy Response EC2 Instance
response_create_ec2 = true

# Deploy Response RDS DB Instance
response_use_rds = true

# Set to null to disable response server ebs data volume - otherwise enter a value in GB
response_ebs_size = "16"

# Snapshot ID used as source for response ebs data volume - Null = empty volume
response_ebs_data_snapshot_identifier = ""

response_env_data = {
  LABKEY_COMPANY_NAME          = "LabKey"
  LABKEY_DISTRIBUTION          = "community"
  LABKEY_DIST_FILENAME         = "LabKey22.7.1-1-response.tar.gz"
  LABKEY_DIST_URL              = "https://lk-binaries.s3-us-west-2.amazonaws.com/downloads/release/response/22.7.1/LabKey22.7.1-1-response.tar.gz"
  LABKEY_SYSTEM_DESCRIPTION    = "MyStudies Response Server"
  LABKEY_VERSION               = "22.7.1"
  POSTGRES_PROVISION_REMOTE_DB = "TRUE"
  TOMCAT_VERSION               = "9.0.65"
}

#
# ---- WCP Server Settings --------------------------------------------------------------------------------------------
#

# Deploy WCP EC2 Instance
wcp_create_ec2 = true

# Deploy WCP RDS DB Instance
wcp_use_rds = true

# Snapshot ID used as source for wcp RDS Database - Null = empty database
wcp_snapshot_identifier = ""

# Snapshot ID used as source for wcp ebs data volume - Null = empty volume
wcp_ebs_data_snapshot_identifier = ""

# Set to null to disable wcp server ebs data volume - otherwise enter a value in GB
wcp_ebs_size = "16"

wcp_env_data = {
  LABKEY_COMPANY_NAME           = "LabKey"
  TOMCAT_VERSION                = "9.0.65"
  WCP_ADMIN_EMAIL               = "donotreply@domain.com"
  WCP_ADMIN_EMAIL               = "donotreply@domain.com"
  WCP_APP_AUDIT_FAIL_EMAIL      = "donotreply@domain.com"
  WCP_APP_CUST_SERVE_EMAIL      = "donotreply@domain.com"
  WCP_APP_EMAIL_TITLE           = "The My Studies Platform Team"
  WCP_APP_NOTIFY_TITLE          = "MyStudies"
  WCP_APP_SERVER_SHUTDOWN_EMAIL = "donotreply@domain.com"
  WCP_CONTACT_EMAIL             = "donotreply@domain.com"
  WCP_DIST_FILENAME             = "wcp_full-22.7.1-41.zip"
  WCP_DIST_URL                  = "https://github.com/FDA-MyStudies/WCP/releases/download/22.7.1/wcp_full-22.7.1-41.zip"
  WCP_FEEDBACK_EMAIL            = "donotreply@domain.com"
  WCP_FROM_EMAIL                = "donotreply@domain.com"
  WCP_PRIVACY_POLICY_URL        = "https://www.fda.gov/AboutFDA/AboutThisWebsite/WebsitePolicies/#privacy"
  WCP_TERMS_URL                 = "https://www.fda.gov/AboutFDA/AboutThisWebsite/WebsitePolicies/"
}

# URL Path used for wcp server health check - e.g. "/mystudies_images/"
wcp_target_group_path = "/mystudies_images/"

# --- end of configuration ---
