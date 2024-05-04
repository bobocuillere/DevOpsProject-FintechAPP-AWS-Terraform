import subprocess
import boto3
import json
import yaml
import os
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env file

with open('vars.yml') as file:
    vars_data = yaml.safe_load(file)
aws_region = vars_data['aws_region']

def get_terraform_output(output_name):
    command = f"cd ../terraform/ && terraform output -raw {output_name}"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()

    if stderr:
        print("Error fetching Terraform output:", stderr.decode())
        return None

    return stdout.decode().strip()

def configure_kubectl():
    kubectl_config_command = get_terraform_output("configure_kubectl")
    if kubectl_config_command:
        subprocess.check_call(kubectl_config_command, shell=True)
    else:
        print("Failed to get 'configure_kubectl' command from Terraform outputs.")

def extract_kubeconfig_info():
    # Ensure the kubeconfig is up-to-date with the correct context
    configure_kubectl()

    # Extract the cluster name from the current context
    cluster_name = subprocess.check_output(
        "kubectl config view --minify -o jsonpath='{.contexts[0].context.cluster}'", shell=True).decode().strip()

    # Extract the API server endpoint
    api_server = subprocess.check_output(
        f"kubectl config view -o jsonpath='{{.clusters[?(@.name==\"{cluster_name}\")].cluster.server}}'", shell=True).decode().strip()

    # Extract the CA certificate
    ca_cert = subprocess.check_output(
        f"kubectl config view --raw -o jsonpath='{{.clusters[?(@.name==\"{cluster_name}\")].cluster.certificate-authority-data}}'", shell=True).decode().strip()

    return api_server, ca_cert

def get_service_account_token():
    # Fetch the token directly from the created secret
    token_output = subprocess.check_output(
        "kubectl get secret prometheus-external-token -n monitoring -o jsonpath='{.data.token}' | base64 --decode", shell=True).decode().strip()
    return token_output

def update_aws_secrets(secret_id, api_server, ca_cert, bearer_token):
    client = boto3.client('secretsmanager', region_name=aws_region)

    secret_dict = {
        'api_server': api_server,
        'ca_cert': ca_cert,
        'bearer_token': bearer_token
    }

    # Try to update the secret, if it doesn't exist, create it
    try:
        client.update_secret(SecretId=secret_id, SecretString=json.dumps(secret_dict))
        print(f"Kubernetes API access information successfully updated in AWS Secrets Manager for secret '{secret_id}'.")
    except client.exceptions.ResourceNotFoundException:
        client.create_secret(Name=secret_id, SecretString=json.dumps(secret_dict))
        print(f"Secret '{secret_id}' not found. A new secret has been created in AWS Secrets Manager with Kubernetes API access information.")

if __name__ == "__main__":
    secret_id = "kubernetes-prometheus"  # Specify the AWS Secrets Manager secret ID

    # Extract API server and CA certificate from kubeconfig
    api_server, ca_cert = extract_kubeconfig_info()

    # Get the service account bearer token from the Secret
    bearer_token = get_service_account_token()

    # Update or create the secret in AWS Secrets Manager
    update_aws_secrets(secret_id, api_server, ca_cert, bearer_token)
