import boto3

ssmc = boto3.Client("ssm", "us-west-2")

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


def get_status_from_ssm(param_name="/slalom-awslab-cloud/flask-app/http-satus-code"):
    status = ssmc.get_parameter(Name=param_name)
    return status["Parameter"]["Value"]