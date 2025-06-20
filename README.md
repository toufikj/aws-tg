# aws-tg

## Overview
This repository contains Terraform and Terragrunt configurations for managing AWS infrastructure. It is structured to support modular and reusable components for deploying resources like EC2 instances, IAM roles, and S3 buckets.

---

## Repository Structure

### Modules
The `modules/` directory contains reusable Terraform modules:
- **`modules/aws/ec2/`**:
  - `main.tf`: Defines resources for EC2 instances, IAM roles, policies, security groups, and the logic for passing user data.
  - `variables.tf`: Contains input variables for the EC2 module, such as instance type, AMI ID, S3 bucket name, GitHub token, repository URLs, and inbound ports.
  - `output.tf`: Outputs key information about the deployed EC2 instance, such as its public IP.
  - `user_data.sh.tftpl`: Template for the EC2 instance's user data script, parameterized for flexible deployment.

### Terragrunt
The `terragrunt/` directory contains Terragrunt configurations for managing environments:
- **`terragrunt/root-config.hcl`**: The root configuration file for Terragrunt, defining global settings including the AWS region.
- **`terragrunt/aws/prod/`**:
  - `prod.hcl`: Environment-specific configuration for the production environment.
  - `ec2-instance/terragrunt.hcl`: Configuration for deploying EC2 instances in the production environment, including all required input variables.

---

## How It Works

### Region Handling
- The AWS region is **not hardcoded** in the Terraform modules. Instead, the region is set in the `root-config.hcl` file and is used by all resources, including the S3 bucket. This ensures that all resources are created in the region specified in your Terragrunt root configuration, providing flexibility and consistency across environments.

### Inputs and Parameterization
- All sensitive and environment-specific values are provided via the `inputs` block in the relevant `terragrunt.hcl` file. This includes:
  - `ami_id`, `instance_type`, `key_name`, `subnet_id`, `instance_name`, `vpc_id`, `volume_size`, `allowed_cidr_blocks`, `tags`, `s3_bucket_name`, `github_token` (sensitive), `static_repo_url`, `static_repo_dir`, `project_repo_url`, `project_repo_dir`, `aws_region`, and `inbound_ports`.
- **Sensitive values** (such as `github_token`) are marked as sensitive in `variables.tf` and should never be committed to version control.
- The `inbound_ports` input is a list of objects, each specifying a port range, protocol, and description, allowing dynamic and flexible security group rules.

### EC2 Module and User Data
1. **IAM Role and Policy**:
   - Creates an IAM role and policy to allow EC2 instances to access and manage S3 buckets and objects.
   - Attaches the role to the EC2 instance via an instance profile.
2. **Security Groups**:
   - Configures security groups dynamically based on the `inbound_ports` input to allow traffic on specified ports (e.g., HTTP, SSH).
3. **User Data**:
   - The `user_data.sh.tftpl` template is rendered with all relevant variables and passed to the EC2 instance.
   - The script performs the following actions:
     - Installs required software (Java, AWS CLI, etc.).
     - Clones the specified static and project repositories using the provided GitHub token if necessary.
     - Creates the S3 bucket if it does not exist.
     - Uploads static assets to the S3 bucket under the `static/` directory.
     - Deploys a Java web application using Apache Tomcat.
     - Configures a systemd shutdown script to upload logs (`cloud-init.log` and `user_data.log`) to the S3 bucket upon instance shutdown.
   - All actions and errors are logged to `/var/log/user_data.log` for troubleshooting.
   - **If the repository is private:** The script uses the provided `github_token` to authenticate with GitHub. If the token is not set or is invalid, cloning a private repository will fail. Always provide a valid token for private repositories in the `github_token` input.

---

## Usage

### Prerequisites
- Install [Terraform](https://www.terraform.io/downloads.html) and [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/).
- Configure your AWS credentials (e.g., using `aws configure`).
- **Create an S3 bucket for remote state:**
  - Before running Terragrunt, you must create an S3 bucket that will be used to store the Terraform remote state files. This bucket must be globally unique.
  - Example (PowerShell):
    ```powershell
    aws s3api create-bucket --bucket <your-terragrunt-state-bucket> --region <your-region> --create-bucket-configuration LocationConstraint=<your-region>
    ```
  - Replace `<your-terragrunt-state-bucket>` and `<your-region>` (e.g., `ap-south-1`) with your values.
- **Update `root-config.hcl` to use the S3 bucket for remote state:**
  - Edit `terragrunt/root-config.hcl` and set the `remote_state` block to use your S3 bucket. Example:
    ```hcl
    remote_state {
      backend = "s3"
      config = {
        bucket         = "<your-terragrunt-state-bucket>"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        region         = "<your-region>"
        encrypt        = true
        # dynamodb_table = "<your-lock-table>" # (optional, for state locking)
      }
    }
    ```

- **Sensitive values:**
  - Never commit real GitHub tokens or other secrets to version control. Use environment variables or secret management tools for production.

### Steps
1. Edit the `inputs` block in `terragrunt/aws/prod/ec2-instance/terragrunt.hcl` to provide all required values, for example:
   ```hcl
   inputs = {
     ami_id            = "ami-06b6e5225d1db5f46"
     instance_type     = "t2.micro"
     key_name          = "account799"
     subnet_id         = "subnet-094555e147f68ef71"
     instance_name     = "login-demo"
     vpc_id            = "vpc-08537c3ca047ee074"
     volume_size       = 10
     allowed_cidr_blocks = ["0.0.0.0/0"]
     tags              = local.tags
     s3_bucket_name    = "my-buc-2025-01"
     github_token      = "<YOUR_GITHUB_TOKEN>" # SENSITIVE
     static_repo_url   = "github.com/toufikj/docker-assignment.git"
     static_repo_dir   = "docker-assignment"
     project_repo_url  = "github.com/toufikj/login-deploy.git"
     project_repo_dir  = "login-deploy"
     aws_region        = "ap-south-1"
     inbound_ports = [
       {
         from_port   = 80
         to_port     = 80
         protocol    = "tcp"
         description = "Allow HTTP traffic"
       },
       {
         from_port   = 22
         to_port     = 22
         protocol    = "tcp"
         description = "Allow SSH traffic"
       }
     ]
   }
   ```
2. Navigate to the desired environment directory (e.g., `terragrunt/aws/prod/ec2-instance/`).
3. Run the following commands in PowerShell:
   ```powershell
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

### Outputs
- Public IP of the EC2 instance.
- S3 bucket name.

---

## Debugging and Logs
- The EC2 instance logs all user data actions to `/var/log/user_data.log`.
- On shutdown, both `/var/log/cloud-init.log` and `/var/log/user_data.log` are uploaded to the S3 bucket under the `logs/` directory.
- You can also check the AWS EC2 console for instance system logs and status.

---

## Notes
- The AWS region for all resources, including the S3 bucket, is set in `root-config.hcl` and not hardcoded in the modules.
- Ensure the S3 bucket name is unique across AWS.
- Modify `variables.tf` to customize the deployment and add/remove variables as needed.
- All sensitive values (such as GitHub tokens) should be handled securely and never committed to version control.