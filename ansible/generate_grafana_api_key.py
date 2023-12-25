import requests
import os
import boto3
import json
import yaml
from dotenv import load_dotenv
import subprocess
import time

load_dotenv()  # This loads the variables from .env into the environment

# Load vars.yml
with open('vars.yml') as file:
    vars_data = yaml.safe_load(file)
aws_region = vars_data['aws_region'] 

def get_terraform_output(output_name):
    command = f" cd ../terraform/ && terraform output -raw {output_name}"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()

    if stderr:
        print("Error fetching Terraform output:", stderr.decode())
        return None

    return stdout.decode().strip()

# Function to generate Grafana API key
def generate_grafana_api_key(grafana_url, admin_user, admin_password):
    headers = {
        "Content-Type": "application/json",
    }
    timestamp = int(time.time())
    payload = {
        "name": f"terraform-api-key-{timestamp}",
        "role": "Admin"
    }
    response = requests.post(f"{grafana_url}/api/auth/keys", headers=headers, json=payload, auth=(admin_user, admin_password))
    if response.status_code == 200:
        return response.json()['key']
        print("API key generated successfully.")
    else:
        print(f"Response status code: {response.status_code}")
        print(f"Response body: {response.text}")
        raise Exception("Failed to generate Grafana API key")

# Function to update AWS Secrets Manager
def update_secret(secret_id, new_grafana_api_key):
    client = boto3.client('secretsmanager', region_name=aws_region)
    secret_dict = json.loads(client.get_secret_value(SecretId=secret_id)['SecretString'])
    secret_dict['grafana_api_key'] = new_grafana_api_key

    client.put_secret_value(SecretId=secret_id, SecretString=json.dumps(secret_dict))

    # Debugging step: Check if the secret is really updated on AWS
    updated_secret_dict = json.loads(client.get_secret_value(SecretId=secret_id)['SecretString'])
    if updated_secret_dict['grafana_api_key'] == new_grafana_api_key:
        print("Secret successfully updated on AWS.")
    else:
        print("Failed to update secret on AWS.")

if __name__ == "__main__":
    grafana_url = os.environ.get('GRAFANA_URL')
    admin_user = os.environ.get('GRAFANA_ADMIN_USER')
    admin_password = os.environ.get('GRAFANA_ADMIN_PASSWORD')
    secret_id = get_terraform_output("rds_secret_arn")  # From the terraform output

    api_key = generate_grafana_api_key(grafana_url, admin_user, admin_password)
    update_secret(secret_id, api_key)