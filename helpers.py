import boto3
import requests
ssmc = boto3.client("ssm", "us-west-2")

def get_instance_az_letter(az=None):
    az = requests.get("http://169.254.169.254/latest/meta-data/placement/availability-zone").text[-1]
    return az

def get_instance_name(az=None, prefix=None):
    if prefix == None:
        prefix = "flask-app"
    if az == None:
        az = get_instance_az_letter()
    instance_name = f"{prefix}-{az}.slalom.awslab.cloud"
    return instance_name

def get_status_from_ssm(param_name="/slalom-awslab-cloud/flask-app/http-status-code"):
    status = ssmc.get_parameter(Name=param_name)
    return status["Parameter"]["Value"]

def update_status_in_ssm(status, param_name="/slalom-awslab-cloud/flask-app/http-status-code"):
    update_command = ssmc.put_parameter(Name=param_name, Value=status, Overwrite=True)
    update_command_status = update_command["ResponseMetadata"]["HTTPStatusCode"]
    return update_command_status