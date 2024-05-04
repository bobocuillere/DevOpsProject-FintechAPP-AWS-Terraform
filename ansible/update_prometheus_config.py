import boto3
import json
import yaml
import os
import re
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Load vars.yml
with open('vars.yml') as file:
    vars_data = yaml.safe_load(file)
aws_region = vars_data['aws_region']
secret_id = 'kubernetes-prometheus'
nlb_tag_key = 'kubernetes.io/cluster/fintech-eks-cluster'
nlb_tag_value = 'owned'

def get_aws_secret(secret_id, aws_region):
    print("Fetching AWS secret...")
    client = boto3.client('secretsmanager', region_name=aws_region)
    response = client.get_secret_value(SecretId=secret_id)
    secret = json.loads(response['SecretString'])
    print(f"Secret fetched: {secret}")
    return secret

def get_nlb_dns_name(tag_key, tag_value, aws_region):
    print(f"Fetching NLB DNS name for tag {tag_key}={tag_value}...")
    elb = boto3.client('elbv2', region_name=aws_region)
    response = elb.describe_load_balancers()

    for lb in response['LoadBalancers']:
        tag_descriptions = elb.describe_tags(ResourceArns=[lb['LoadBalancerArn']])
        for tag_desc in tag_descriptions['TagDescriptions']:
            for tag in tag_desc['Tags']:
                if tag['Key'] == tag_key and tag['Value'] == tag_value:
                    print(f"Found NLB DNS name: {lb['DNSName']}")
                    return lb['DNSName']
    print("NLB DNS name not found.")
    return None

def update_prometheus_config(secrets, nlb_dns_name):
    file_path = 'roles/prometheus/templates/prometheus.yml.j2'
    with open(file_path, 'r') as file:
        config_content = file.readlines()

    # Debugging: print relevant lines before replacement
    for line in config_content:
        if 'targets:' in line or 'api_server:' in line:
            print(f"Before replacement: {line.strip()}")

    updated_content = []
    skip_next_line = False
    for line in config_content:
        if skip_next_line:
            skip_next_line = False
            continue
        if 'targets:' in line:
            updated_content.append(f'  - targets:\n    - {nlb_dns_name}\n')
            skip_next_line = True  # Skip the next line, which is the old target
        elif 'api_server:' in line:
            updated_content.append(f'    api_server: "{secrets["api_server"]}"\n')
        else:
            updated_content.append(line)

    # Debugging: print relevant lines after replacement
    for line in updated_content:
        if 'targets:' in line or 'api_server:' in line:
            print(f"After replacement: {line.strip()}")

    with open(file_path, 'w') as file:
        file.writelines(updated_content)
    print("Prometheus configuration successfully updated.")

if __name__ == '__main__':
    secrets = get_aws_secret(secret_id, aws_region)
    nlb_dns_name = get_nlb_dns_name(nlb_tag_key, nlb_tag_value, aws_region)

    if not nlb_dns_name or not secrets.get('api_server'):
        raise Exception("NLB DNS name or API server URL not found. Please check your AWS environment and secret configurations.")

    update_prometheus_config(secrets, nlb_dns_name)
