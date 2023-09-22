data "terraform_remote_state" "flask_app" {
  backend "s3" {
    bucket = "gsiders-tf"
    key = "aws-cert/flask-app/terraform.tfstate"
    region = "us-east-1"
   }
}