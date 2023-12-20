# Fintech DevOps Project: A Journey from Development to Deployment

## Application Description

The Fintech Cloud Project presents a mock financial technology application, designed and developed by me Sophnel Merzier :) to simulate a typical fintech environment. The application features a RESTful API developed using Flask, a popular Python web framework. It provides functionalities like user registration, account management, and transaction processing, all managed through an easy-to-use web interface.

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

For local development and testing, the Fintech Cloud Project can be run using Docker Compose, which simplifies the process of setting up and managing the application's environment.

### Requirements for Local Testing

- Docker and Docker Compose installed on your machine.
- Local clone of the repository.

### Setting Up the Local Environment

1. **Configure Environment Variables**:
   - Create the image
   - Create a `.env` file in the root directory.
   - Add necessary environment variables, for example:
     ```
     SECRET_KEY=your_secret_key
     DATABASE_URI=postgresql://username:password@localhost:5432/your_db
     ```
   - Adjust the `DATABASE_URI` to point to your local or a test database.

2. **Database Setup**:
   - Ensure you have PostgreSQL installed and running on your local machine.
   - Create a new database and user for the application:
     ```
     psql -U postgres
     CREATE DATABASE your_db;
     CREATE USER username WITH ENCRYPTED PASSWORD 'password';
     GRANT ALL PRIVILEGES ON DATABASE your_db TO username;
     ```

3. **Build and Run with Docker Compose**:
   - Navigate to the root directory of the project.
   - Run the following command to build and start the containers:
     ```
     docker-compose up --build
     ```
   - This will start the web application and any other services defined in your `docker-compose.yml` file.

4. **Accessing the Application**:
   - Once the containers are up and running, the web application should be accessible via `http://localhost:5000` or the port you've configured.

### Testing the Application

- Run any tests defined in your application to ensure functionality:

### Local Development Workflow

- Make changes to the application code.
- Test the changes locally using Docker Compose.
- Once you're satisfied with the changes, commit and push to the repository.

### Cleanup

- To stop and remove the containers, use:
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
