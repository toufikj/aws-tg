# aws-tg

## Overview
This repository contains Terraform and Terragrunt configurations for managing AWS infrastructure. It is structured to support modular and reusable components for deploying resources like EC2 instances, IAM roles, and S3 buckets.

---

## Repository Structure

### Modules
The `modules/` directory contains reusable Terraform modules:
- **`modules/aws/ec2/`**:
  - `main.tf`: Defines resources for EC2 instances, IAM roles, policies, and security groups.
  - `variables.tf`: Contains input variables for the EC2 module, such as instance type, AMI ID, and S3 bucket name.
  - `output.tf`: Outputs key information about the deployed EC2 instance, such as its public IP.

### Terragrunt
The `terragrunt/` directory contains Terragrunt configurations for managing environments:
- **`terragrunt/root-config.hcl`**: The root configuration file for Terragrunt, defining global settings including the AWS region.
- **`terragrunt/aws/prod/`**:
  - `prod.hcl`: Environment-specific configuration for the production environment.
  - `ec2-instance/terragrunt.hcl`: Configuration for deploying EC2 instances in the production environment.

---

## How It Works

### Region Handling
- The AWS region is **not hardcoded** in the Terraform modules. Instead, the region is set in the `root-config.hcl` file and is used by all resources, including the S3 bucket. This ensures that all resources are created in the region specified in your Terragrunt root configuration, providing flexibility and consistency across environments.

### EC2 Module
1. **IAM Role and Policy**:
   - Creates an IAM role and policy to allow EC2 instances to access S3 buckets.
   - Attaches the role to the EC2 instance via an instance profile.

2. **Security Groups**:
   - Configures security groups to allow traffic on specific ports (e.g., HTTP, HTTPS, SSH).

3. **User Data**:
   - Installs required software (e.g., Java, AWS CLI).
   - Deploys a web application using Apache Tomcat.
   - Configures a shutdown script to upload logs to the S3 bucket.

### Terragrunt
- Simplifies the management of Terraform configurations by providing environment-specific overrides and remote state management.
- The region for all resources is controlled centrally via `root-config.hcl`.

---

## Usage

### Prerequisites
- Install Terraform and Terragrunt.
- Configure AWS credentials.
- **Before running locally:**  
  Edit the `user_data` section in `modules/aws/ec2/main.tf` and replace `${GITHUB-TOKEN}` with your personal GitHub token for private repository access.


### Steps
1. Navigate to the desired environment directory (e.g., `terragrunt/aws/prod/ec2-instance/`).
2. Run the following commands:
   ```bash
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

### Outputs
- Public IP of the EC2 instance.
- S3 bucket name.

---

## Notes
- The AWS region for all resources, including the S3 bucket, is set in `root-config.hcl` and not hardcoded in the modules.
- Ensure the S3 bucket name is unique across AWS.
- Modify `variables.tf` to customize the deployment.