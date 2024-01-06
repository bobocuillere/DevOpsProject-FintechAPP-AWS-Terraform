# Fintech DevOps Project: A Journey from Development to Deployment

## Application Description

The Financial (Fintech) Cloud Project presents a mock financial technology application, designed and developed by me Sophnel Merzier :) to simulate a typical fintech environment. The application features a RESTful API developed using Flask, a popular Python web framework. It provides functionalities like user registration, account management, and transaction processing, all managed through an easy-to-use web interface.

### Core Features

- **User Management**: Secure registration and authentication system.
- **Account Handling**: Creation and management of user financial accounts.
- **Transaction Processing**: Facility to perform and track financial transactions.

### Development and Deployment Journey

This project encapsulates the full software development lifecycle, starting with a basic mock application and culminating in a cloud-hosted solution.

1. **Local Development**: Initially, the application is developed locally, focusing on Flask for backend operations and integrating database management for user and transaction data.
   
2. **Dockerization**: The application is then containerized using Docker, demonstrating how Docker aids in maintaining consistency across various environments and simplifies the deployment process.

3. **Cloud Deployment on AWS**: Transitioning to AWS, the project employs services like EKS for Kubernetes orchestration and RDS for database management, AWS secrets, ECS and other services.

4. **Infrastructure as Code (IaC)**: Utilizing Terraform and Ansible, the project highlights the advantages of IaC in automating and replicating infrastructure setups efficiently.

## Scope and Learning Objectives

- **Flask-based API Development**: Learn to build a RESTful API with Flask, managing routing, requests, and CRUD operations.
- **Containerization and Docker**: Understand how to package and run the application in Docker containers for consistency and portability.
- **AWS Deployment**: Explore deploying a Flask application on AWS using EKS and RDS, understanding the nuances of cloud services and Kubernetes.
- **IaC with Terraform and Ansible**: Experience firsthand the power of Terraform in managing cloud resources, emphasizing the importance of IaC in DevOps.
- **CI/CD Integration**: Implement CI/CD pipelines to automate testing and deployment, ensuring faster delivery and high-quality code.

### Architecture

- **Frontend**: A Flask-based web application.
- **Backend**: Managed by AWS RDS (PostgreSQL).
- **Infrastructure**: Managed using Terraform, with AWS EKS for orchestration and EC2 instances.
- **CI/CD**: Planned integration with GitHub Actions for automated workflows.
- **Monitoring**: Planned setup with Prometheus and Grafana.

## Prerequisites

- AWS Account
- Terraform
- Kubernetes (kubectl)
- Docker
- AWS CLI (configured)
- Pyenv (optional, for Python version management)

## Running the Application

1. **Infrastructure Setup with Terraform**:
   - Ensure a Terraform backend is set up with an S3 bucket and DynamoDB table.
   - Modify `backend.tf` to match your AWS configuration.
   - Minimum 3 nodes in the `terraform.tfvars` file to have enough CPU/RAM to run the mock app.
   - Run the following commands in the `terraform` directory:
     ```
     cd terraform
     terraform init
     terraform apply
     ```

2. **Kubernetes Configuration**:
   - Use the `terraform output` command to get the `update-kubeconfig` command.
   - Run the provided command to configure kubectl for your EKS cluster.

3. **Deploying to Kubernetes**:
   - First, Give the rights to execute the `wrapper-rds-k8s.sh` script in the `k8s`folder
     ````
     chmod +x ./wrapper-rds-k8s.sh`
     ````
   - Run the script
     ````
      sudo ./wrapper-rds-k8s.sh
     ````
   - 
     Apply for the Ingress controller:
     ```
     kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml
     ```
   - Wait for the Ingress controller to be fully deployed.
   - Apply the Kubernetes manifests from the `k8s` directory:
     ```
     kubectl apply -f k8s/
     ```

4. **Accessing the Application**:
   - Use `kubectl get ingress` and wait for the address to appear to access the application.

5. **Monitoring Setup** (Planned):
   - Deploy Prometheus and Grafana using provided Ansible playbooks.

## CI/CD Workflow (Planned)

The project will integrate GitHub Actions for continuous integration and delivery, automating the deployment process upon every code commit to the repository. This will streamline the workflow, ensuring code consistency and deployment efficiency.

## Local Development and Testing

For local development and testing, the Fintech Cloud Project can be run using Docker Compose.

### Requirements for Local Testing

- Docker and Docker Compose installed on your machine.
- Local clone of the repository.

### Setting Up the Local Environment

1. **Configure Environment Variables**:
   - Create a `.env` file in the root directory of the project.
   - Define the necessary environment variables. For example:
     ```
     SECRET_KEY=your_secret_key
     POSTGRES_DB=mydatabase
     POSTGRES_USER=myuser
     POSTGRES_PASSWORD=mypass
     ```

2. **Docker Compose Setup**:

   - The `docker-compose.yml` file define the services needed for the application, such as the web server and the PostgreSQL database.
   - Make sure the PostgreSQL service environment match the value in the *.env* file.

3. **Build and Run with Docker Compose**:
   - In the root directory of the project, run the following command to build and start the containers:
     ```
     docker-compose up --build
     ```
   - This command builds the Docker image for the web application and starts all the services defined in the `docker-compose.yml`.

4. **Waiting for Database Readiness**:
   - The script (e.g., `wait-for-postgres.sh`) in the web application container goal is to wait for the PostgreSQL service to be ready before starting the Flask application.
   - This script should attempt to connect to the PostgreSQL database and only proceed once a successful connection is established.

5. **Accessing the Application**:
   - Once the containers are up and running, the web application should be accessible at `http://localhost:5000` or the configured port.

### Testing the Application

- Ensure your application includes tests to verify functionality.
- Run these tests to confirm that your application behaves as expected.

### Local Development Workflow

- Make changes to the application code as needed.
- Test the changes locally using Docker Compose to ensure they work as expected in the containerized environment.
- Commit and push the satisfactory changes to the repository.

### Cleanup

- To stop and remove the containers, along with their network, use the following command:

```
docker-compose down
````

## Repository Structure

- `ansible/`: Ansible playbooks and roles for Prometheus and Grafana.
- `k8s/`: Kubernetes manifests including ConfigMaps, Secrets, and Ingress.
- `src/`: Source code of the Flask application.
- `terraform/`: Terraform modules for AWS infrastructure.

## Contributing

Contributions are welcome. Please adhere to best practices for coding, testing, and documentation.
