import json
import boto3
import yaml

# Load vars.yml
with open('vars.yml') as file:
    vars_data = yaml.safe_load(file)
aws_region = vars_data['aws_region'] 

def get_instance_ip(instance_name):
    ec2 = boto3.client('ec2', region_name=aws_region)

    response = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:Name', 'Values': [instance_name]},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            ip_address = instance.get('PublicIpAddress')
            print(f"IP for {instance_name}: {ip_address}")
            return ip_address
    print(f"No running instance found for {instance_name}")
    return None

def update_inventory():
    grafana_ip = get_instance_ip('Grafana-Server')
    prometheus_ip = get_instance_ip('Prometheus-Server')

    inventory_content = f'''
all:
  children:
    grafana:
      hosts:
        {grafana_ip}:
    prometheus:
      hosts:
        {prometheus_ip}:
    '''

    with open('./inventory.yml', 'w') as file:
        file.write(inventory_content.strip())

    with open('./roles/grafana/templates/grafana.ini.j2', 'r') as file:
        lines = file.readlines()

    with open('./roles/grafana/templates/grafana.ini.j2', 'w') as file:
        for line in lines:
            if line.strip().startswith('domain'):
                file.write(f'domain = {grafana_ip}\n')
            else:
                file.write(line)

def update_env_file(grafana_ip, prometheus_ip):
    env_content = f'''
export GRAFANA_URL='http://{grafana_ip}:3000'
export GRAFANA_ADMIN_USER='admin'
export GRAFANA_ADMIN_PASSWORD='admin'
export PROMETHEUS_URL='http://{prometheus_ip}:9090'
'''
    with open('.env', 'w') as file:
        file.write(env_content.strip())

if __name__ == '__main__':
    update_inventory()
    grafana_ip = get_instance_ip('Grafana-Server')
    prometheus_ip = get_instance_ip('Prometheus-Server')
    update_env_file(grafana_ip, prometheus_ip)

