import boto3
import json
import yaml
import os
import subprocess
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Load vars.yml
with open('vars.yml') as file:
    vars_data = yaml.safe_load(file)
aws_region = vars_data['aws_region']
secret_id = 'kubernetes-prometheus'

def get_terraform_output(output_name):
    command = f"cd ../terraform/ && terraform output -raw {output_name}"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()

    if stderr:
        print(f"Error fetching Terraform output: {stderr.decode()}")
        return None

    return stdout.decode().strip()

def configure_kubectl():
    kubectl_config_command = get_terraform_output("configure_kubectl")
    if kubectl_config_command:
        subprocess.check_call(kubectl_config_command, shell=True)
    else:
        print("Failed to get 'configure_kubectl' command from Terraform outputs.")

def extract_kubeconfig_info():
    configure_kubectl()
    cluster_name = subprocess.check_output(
        "kubectl config view --minify -o jsonpath='{.contexts[0].context.cluster}'", shell=True).decode().strip()
    api_server = subprocess.check_output(
        f"kubectl config view -o jsonpath='{{.clusters[?(@.name==\"{cluster_name}\")].cluster.server}}'", shell=True).decode().strip()
    ca_cert = subprocess.check_output(
        f"kubectl config view --raw -o jsonpath='{{.clusters[?(@.name==\"{cluster_name}\")].cluster.certificate-authority-data}}'", shell=True).decode().strip()
    return api_server, ca_cert

def get_service_account_token():
    # Fetch the token directly from the created secret
    token_output = subprocess.check_output(
        "kubectl get secret prometheus-external-token -n monitoring -o jsonpath='{.data.token}' | base64 --decode", shell=True).decode().strip()
    return token_output

def update_aws_secrets(api_server, ca_cert, bearer_token):
    client = boto3.client('secretsmanager', region_name=aws_region)
    secret_dict = {'api_server': api_server, 'ca_cert': ca_cert, 'bearer_token': bearer_token}

    try:
        client.update_secret(SecretId=secret_id, SecretString=json.dumps(secret_dict))
        print(f"Updated secret '{secret_id}' in AWS Secrets Manager.")
    except client.exceptions.ResourceNotFoundException:
        client.create_secret(Name=secret_id, SecretString=json.dumps(secret_dict))
        print(f"Created new secret '{secret_id}' in AWS Secrets Manager.")

if __name__ == '__main__':
    api_server, ca_cert = extract_kubeconfig_info()
    bearer_token = get_service_account_token()
    update_aws_secrets(api_server, ca_cert, bearer_token)
