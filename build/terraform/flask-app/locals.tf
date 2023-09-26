locals {
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  ec2_role_name = data.terraform_remote_state.iam.outputs.ec2_role_name
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  ec2_instance_profile_name = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
  hosted_zone_id     = "Z0929837KI7V4LSZF7ZR"
  region_shorthand = {
    "us-east-1" : "usea1"
    "us-west-2" : "uswe2"
    "ap-southeast-1" : "apse1"
  } 
  az_letters         = ["a", "b", "c", "d"]
  dns_weights        = ["200", "100"]
}

