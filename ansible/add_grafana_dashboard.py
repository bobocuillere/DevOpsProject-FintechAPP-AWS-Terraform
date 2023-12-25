import requests
import boto3
import json
import os
import yaml
import subprocess
from dotenv import load_dotenv

load_dotenv()  # This loads the variables from .env into the environment

# Load vars.yml
with open('vars.yml') as file:
    vars_data = yaml.safe_load(file)
aws_region = vars_data['aws_region'] 

def get_terraform_output(output_name):
    command = f"cd ../terraform && terraform output -raw {output_name}"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()

    if stderr:
        print("Error fetching Terraform output:", stderr.decode())
        return None

    return stdout.decode().strip()

def get_grafana_api_key(secret_id):
    client = boto3.client('secretsmanager', region_name=get_terraform_output("aws_region"))
    secret = json.loads(client.get_secret_value(SecretId=secret_id)['SecretString'])
    return secret['grafana_api_key']


def add_prometheus_data_source(grafana_url, api_key, prometheus_url):
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    # Check if data source exists
    get_response = requests.get(f"{grafana_url}/api/datasources/name/Prometheus", headers=headers)
    
    if get_response.status_code == 200:
        # Data source exists, update it
        data_source_id = get_response.json()['id']
        data_source_config = get_response.json()
        data_source_config['url'] = prometheus_url
        update_response = requests.put(
            f"{grafana_url}/api/datasources/{data_source_id}",
            headers=headers,
            json=data_source_config
        )
        if update_response.status_code == 200:
            print("Prometheus data source updated successfully.")
        else:
            print(f"Failed to update Prometheus data source: {update_response.content}")
    else:
        # Data source does not exist, create it
        data_source_config = {
            "name": "Prometheus",
            "type": "prometheus",
            "access": "proxy",
            "url": prometheus_url,
            "isDefault": True
        }
        create_response = requests.post(f"{grafana_url}/api/datasources", headers=headers, json=data_source_config)
        if create_response.status_code == 200:
            print("New Prometheus data source added successfully.")
        else: 
            print(f"Failed to add as a new data source: {create_response.content}") 


def add_dashboard(grafana_url, api_key, dashboard_json):
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    response = requests.post(f"{grafana_url}/api/dashboards/db", headers=headers, json=dashboard_json)
    if response.status_code == 200:
        print("Dashboard added successfully.")
    else:
        print(f"Failed to add dashboard: {response.content}")

if __name__ == "__main__":
    grafana_url = os.environ.get('GRAFANA_URL')
    secret_id = get_terraform_output("rds_secret_arn")  # From the terraform output
    dashboard_json = {
        "dashboard": {
            "id": None,
            "title": "Simple Prometheus Dashboard",
            "timezone": "browser",
            "panels": [
                {
                    "type": "graph",
                    "title": "Up Time Series",
                    "targets": [
                        {
                            "expr": "up",
                            "format": "time_series",
                            "intervalFactor": 2,
                            "refId": "A"
                        }
                    ],
                    "gridPos": {
                        "h": 9,
                        "w": 12,
                        "x": 0,
                        "y": 0
                    }
                }
            ]
        }
    }

    api_key = get_grafana_api_key(secret_id)
    prometheus_url = os.environ.get('PROMETHEUS_URL') 
    add_prometheus_data_source(grafana_url, api_key, prometheus_url)
    add_dashboard(grafana_url, api_key, dashboard_json)
