instance_type         = "t3.micro"
instance_count        = 1
bastion_instance_type = "t3.micro"
public_subnets = {
  "public-1" = { cidr = "10.0.1.0/24", az = "us-east-2a" }
  "public-2" = { cidr = "10.0.2.0/24", az = "us-east-2b" }
}
private_subnets = {
  "private-1" = { cidr = "10.0.3.0/24", az = "us-east-2a" }
  "private-2" = { cidr = "10.0.4.0/24", az = "us-east-2b" }
}

region                = "us-east-2"
#target_groups      = []
#target_users       = ["jane.smith"]
environment        = "prod"
app_name           = "prod-app"
ami_id             = "ami-0741dc526e1106ae5"
project            = "3 tier App"