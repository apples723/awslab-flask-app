#UPDATE THESE VARS
appname = "app1"
env = "dev"
az = "a"
region_shorthand = "uswe2"
destination = "awslab-flask"
destination_port = "8000"

# Template content
template_content = '''
{{
    acme_dns route53
}}

https://{appname}-{az}.{env}.{region_shorthand}.slalom.awslab.cloud {{
  reverse_proxy {destination}:{destination_port}
}}

https://{appname}.{env}.{region_shorthand}.slalom.awslab.cloud {{ 
    reverse_proxy {destination}:{destination_port}
}}
'''


# Populate template with variables
populated_content = template_content.format(
    appname=appname,
    env=env,
    az=az,
    region_shorthand=region_shorthand,
    destination=destination,
    destination_port=destination_port
)

# Save to Caddyfile
with open("Caddyfile", "w") as f:
    f.write(populated_content)

print("Caddyfile has been generated.")