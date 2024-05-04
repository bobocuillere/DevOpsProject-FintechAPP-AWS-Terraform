import boto3
import json
import os
import yaml
from dotenv import load_dotenv
import paramiko
import configparser
import re
import base64
import logging

# Load environment variables
load_dotenv()
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Load vars.yml
with open('vars.yml') as file:
    vars_data = yaml.safe_load(file)
aws_region = vars_data['aws_region'] 

secret_id = 'kubernetes-prometheus'

def get_secret(secret_id, aws_region):
    """Fetch secret from AWS Secrets Manager."""
    logging.info(f"Fetching secret with id {secret_id} from AWS Secrets Manager in region {aws_region}")
    client = boto3.client('secretsmanager', region_name=aws_region)
    response = client.get_secret_value(SecretId=secret_id)
    secret = json.loads(response['SecretString'])
    logging.info(f"Successfully fetched secret with id {secret_id}")
    return secret

def get_ansible_config():
    """Parse ansible.cfg and return the remote user and private key path."""
    config = configparser.ConfigParser()
    config.read('ansible.cfg')
    return config['defaults']['remote_user'], config['defaults']['private_key_file']

def get_prometheus_host():
    """Parse the Ansible inventory file and return the Prometheus host."""
    with open('inventory.yml', 'r') as file:
        inventory = yaml.safe_load(file)
        return list(inventory['all']['children']['prometheus']['hosts'].keys())[0]

def update_prometheus_config(secrets, hostname, username, private_key_path):
    """Update bearer.token and k8s-ca.crt files with actual values on the remote server and restart the Prometheus service."""
    logging.info(f"Updating Prometheus config on host {hostname} with user {username} and key {private_key_path}")
    private_key = paramiko.RSAKey(filename=private_key_path)
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname, username=username, pkey=private_key)

    # Open a new shell session
    shell = ssh.invoke_shell()

    # Get the bearer token and update the file
    bearer_token = secrets['bearer_token']
    shell.send(f'echo "{bearer_token}" | sudo tee /opt/prometheus-2.26.0.linux-amd64/bearer.token\n')
    shell.send('exit\n')
    shell.recv(1000)  # Wait for the command to finish
    logging.info("Updated bearer.token file")

    
    # Update the k8s-ca.crt file
    ca_secrets_decode = base64.b64decode(secrets['ca_cert'])
    print(ca_secrets_decode)
    ca_cert_content = f"{ca_secrets_decode.decode('utf-8')}"
    shell = ssh.invoke_shell()  # Start a new shell session for the next command
    shell.send(f'echo "{ca_cert_content}"| sudo tee /opt/prometheus-2.26.0.linux-amd64/k8s-ca.crt\n')
    shell.send('exit\n')
    shell.recv(1000)  # Wait for the command to finish
    logging.info("Updated k8s-ca.crt file")

    # Read the content of prometheus.yml.j2 and update the prometheus.yml on the server
    with open('roles/prometheus/templates/prometheus.yml.j2', 'r') as file:
        prometheus_config_content = file.read()
    shell = ssh.invoke_shell()
    shell.send(f'echo "{prometheus_config_content}" | sudo tee /opt/prometheus-2.26.0.linux-amd64/prometheus.yml\n')
    shell.send('exit\n')
    shell.recv(1000)  # Wait for the command to finish
    logging.info("Updated prometheus.yml configuration")

    # Restart the Prometheus service
    ssh.exec_command('sudo systemctl restart prometheus')
    logging.info("Restarted Prometheus service")

    ssh.close()

if __name__ == '__main__':
    # Fetch secrets from AWS Secrets Manager
    secrets = get_secret(secret_id, aws_region)

    # Get the username and private key path from ansible.cfg
    username, private_key_path = get_ansible_config()

    # Get the Prometheus host from the Ansible inventory file
    hostname = get_prometheus_host()

    # Update the Prometheus configuration files on the remote server
    update_prometheus_config(secrets, hostname, username, private_key_path)

