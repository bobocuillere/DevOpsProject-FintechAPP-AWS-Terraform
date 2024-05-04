#!/bin/bash

cd ../terraform

# Refresh the Terraform state file
terraform refresh

SECRET_ARN=$(terraform output -raw rds_secret_arn)
REGION=$(terraform output -raw aws_region)
PROMETHEUS_IP=$(terraform output -raw prometheus_instance_ip)

# Fetch secrets
REGION=$(terraform output -raw aws_region)
DB_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --region $REGION --query 'SecretString' --output text)
DB_USERNAME=$(echo $DB_CREDENTIALS | jq -r .username)
DB_PASSWORD=$(echo $DB_CREDENTIALS | jq -r .password)
DB_ENDPOINT=$(terraform output -raw rds_instance_endpoint)
DB_NAME=$(terraform output -raw rds_db_name)

cd -
# Create Kubernetes secret manifest
cat <<EOF > db-credentials.yaml
apiVersion: v1
kind: Secret
metadata:
  name: fintech-db-secret
type: Opaque
data:
  username: $(echo -n $DB_USERNAME | base64)
  password: $(echo -n $DB_PASSWORD | base64)
EOF

# Create Kubernetes ConfigMap manifest for database configuration
cat <<EOF > db-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fintech-db-config
data:
  db_endpoint: $DB_ENDPOINT
  db_name: $DB_NAME
EOF

# Replace the placeholder in the template with the actual Prometheus IP
sed "s/<Prometheus-Server-IP>/${PROMETHEUS_IP}/g" metrics_ingress.yaml.tpl > metrics_ingress_final.yaml