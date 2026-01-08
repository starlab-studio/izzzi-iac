# IZZZI Infrastructure as Code

![Terraform Version](https://img.shields.io/static/v1?label=Terraform&message=1.7.5&color=blue)
![Ansible Version](https://img.shields.io/static/v1?label=Ansible&message=2.10+&color=red)
![Digital Ocean](https://img.shields.io/static/v1?label=Provider&message=Digital%20Ocean&color=0080FF)

Hub for creating and managing the required infrastructure for IZZZI apps deployment. This repository contains Terraform configurations for provisioning cloud infrastructure and Ansible playbooks for application deployment, ensuring a robust and scalable implementation of the IZZZI platform.

## Overview

This infrastructure as code project manages the complete deployment pipeline for IZZZI:

- **Terraform**: Provisions infrastructure on Digital Ocean (Droplets, VPC, Firewalls, Spaces)
- **Ansible**: Configures servers and deploys the application stack using Docker Swarm
- **Makefile**: Provides convenient commands for common operations

## Requirements

| Tool                                                                | Version | Mandatory | Usage                                                             |
| ------------------------------------------------------------------- | ------- | --------- | ----------------------------------------------------------------- |
| [Terraform](https://terraform.io)                                   | 1.7.5+  | Yes       | Used to provision and manage infrastructure resources.            |
| [Ansible](https://www.ansible.com)                                  | 2.10+   | Yes       | Used to configure servers and deploy application stacks.          |
| [terraform-docs](https://github.com/terraform-docs/terraform-docs)  | 0.12.1  | No        | Used to generate Terraform documentation.                         |
| [tflint](https://github.com/wata727/tflint)                         | 0.33.0  | No        | Terraform linter focused on possible errors, best practices, etc. |
| [Digital Ocean CLI](https://docs.digitalocean.com/reference/doctl/) | Latest  | No        | Optional CLI for managing Digital Ocean resources.                |

### Terraform

Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. This includes low-level components like compute instances, storage, and networking; and high-level components like DNS entries and SaaS features.

- [Getting started with Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)
- [Setup Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Ansible

Ansible is an automation tool that simplifies configuration management, application deployment, and task automation. It uses SSH to connect to servers and execute tasks defined in playbooks.

- [Getting started with Ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html)
- [Installation guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

## Project structure

```
izzzi-iac/
├── terraform/                        # Terraform configurations
│   ├── envs/                         # Deployment environments
│   │   ├── dev/                      # Development environment
│   │   │   ├── backend.tf            # Terraform backend configuration
│   │   │   ├── main.tf               # Main infrastructure resources
│   │   │   ├── providers.tf          # Provider definitions
│   │   │   ├── variables.tf          # Variable definitions
│   │   │   ├── outputs.tf            # Output values
│   │   │   ├── versions.tf           # Provider versions
│   │   │   ├── terraform.tfvars      # Environment-specific variables
│   │   │   └── terraform.tfvars.example  # Example variables file
│   │   └── prod/                     # Production environment
│   │       ├── backend.tf
│   │       ├── main.tf
│   │       ├── providers.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars.example
│   ├── modules/                      # Reusable Terraform modules
│   │   ├── networking/               # VPC and networking configuration
│   │   ├── droplet/                  # Digital Ocean Droplets (servers)
│   │   ├── firewall/                 # Firewall rules
│   │   ├── spaces/                   # Digital Ocean Spaces (object storage)
│   │   └── [module-name]/            # Each module contains:
│   │       ├── main.tf               # Module resources
│   │       ├── variables.tf          # Module inputs
│   │       ├── outputs.tf            # Module outputs
│   │       ├── versions.tf           # Provider versions
│   │       └── README.md             # Module documentation
│   ├── providers.tf                  # Global provider configuration
│   ├── variables.tf                  # Global variables
│   ├── versions.tf                   # Global provider versions
│   └── config/                       # Configuration files (AWS profile, etc.)
├── ansible/                          # Ansible playbooks and roles
│   ├── playbooks/                    # Ansible playbooks
│   │   ├── init-cluster.yml          # Initialize Docker Swarm cluster
│   │   ├── deploy.yml                # Deploy application stack
│   │   ├── backup.yml                # Backup database
│   │   ├── rollback.yml              # Rollback service
│   │   ├── scale.yml                 # Scale service
│   │   └── site.yml                  # Full site playbook
│   ├── roles/                        # Ansible roles
│   │   ├── common/                   # Common server configuration
│   │   ├── docker/                   # Docker installation
│   │   ├── swarm-manager/            # Docker Swarm manager setup
│   │   ├── swarm-worker/             # Docker Swarm worker setup
│   │   ├── deploy-stack/             # Application stack deployment
│   │   └── backup/                   # Database backup
│   ├── inventory/                    # Ansible inventory files
│   │   ├── dev.yml                   # Development inventory
│   │   └── prod.yml                  # Production inventory
│   ├── group_vars/                   # Group variables
│   │   └── all.yml                   # Variables for all groups
│   └── ansible.cfg                   # Ansible configuration
├── Makefile                          # Convenient commands wrapper
├── compose.yaml                      # Docker Compose for local testing
├── GETTING_STARTED.md                # Complete deployment guide
└── README.md                         # This file
```

## Quick Start

### 1. Prerequisites

- Digital Ocean account with API token
- SSH key pair
- Terraform and Ansible installed

For detailed setup instructions, see [GETTING_STARTED.md](./GETTING_STARTED.md).

### 2. Configuration

1. Create a `.env` file at the root with your credentials:

   ```bash
   export TF_VAR_do_token="your-digital-ocean-token"
   export TF_VAR_spaces_access_id="your-spaces-access-key"
   export TF_VAR_spaces_secret_key="your-spaces-secret-key"
   export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
   # ... other variables (see GETTING_STARTED.md)
   ```

2. Load the environment variables:

   ```bash
   source .env
   ```

3. Configure Terraform variables:
   ```bash
   cd terraform/envs/dev
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

### 3. Deploy Infrastructure

#### Using Makefile (Recommended)

```bash
# Initialize Terraform
make init-dev

# Plan changes
make plan-dev

# Apply changes
make apply-dev

# Full deployment (Terraform + Ansible)
make full-deploy-dev
```

#### Using Terraform directly

```bash
cd terraform/envs/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Deploy Application

After infrastructure is provisioned:

1. Update Ansible inventory with server IPs:

   ```bash
   # Get IPs from Terraform outputs
   cd terraform/envs/dev
   terraform output manager_ip
   terraform output worker_ips

   # Update ansible/inventory/dev.yml with these IPs
   ```

2. Deploy with Ansible:

   ```bash
   # Using Makefile
   make ansible-init-dev      # Initialize Docker Swarm
   make ansible-deploy-dev    # Deploy application

   # Or directly
   cd ansible
   ansible-playbook playbooks/init-cluster.yml -i inventory/dev.yml
   ansible-playbook playbooks/deploy.yml -i inventory/dev.yml
   ```

## Available Commands

The `Makefile` provides convenient commands for common operations. Run `make help` to see all available commands.

### Terraform Commands

- `make init-dev` / `make init-prod` - Initialize Terraform
- `make plan-dev` / `make plan-prod` - Plan infrastructure changes
- `make apply-dev` / `make apply-prod` - Apply infrastructure changes
- `make destroy-dev` / `make destroy-prod` - Destroy infrastructure
- `make output-dev` / `make output-prod` - Show Terraform outputs

### Ansible Commands

- `make ansible-init-dev` / `make ansible-init-prod` - Initialize Docker Swarm cluster
- `make ansible-deploy-dev` / `make ansible-deploy-prod` - Deploy application stack
- `make ansible-deploy-dev-tag TAG=v1.2.3` - Deploy with specific image tag
- `make ansible-backup-dev` / `make ansible-backup-prod` - Backup database
- `make ansible-rollback-dev SERVICE=frontend` - Rollback a service
- `make ansible-scale-dev SERVICE=backend REPLICAS=3` - Scale a service
- `make ansible-ping-dev` / `make ansible-ping-prod` - Test connectivity

### Full Deployment

- `make full-deploy-dev` - Complete deployment (Terraform + Ansible) for DEV
- `make full-deploy-prod` - Complete deployment (Terraform + Ansible) for PROD

## How to use this project

### Terraform Backend Configuration

The Terraform state is stored in a Digital Ocean Spaces bucket. Configure the backend in each environment's `backend.tf` file.

Example configuration:

```hcl
terraform {
  backend "s3" {
    endpoint   = "https://fra1.digitaloceanspaces.com"
    region     = "fra1"
    bucket     = "izzzi-terraform-state"
    key        = "dev/terraform.tfstate"
    encrypt    = true
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}
```

**Note**: You need to create the Spaces bucket manually before first use.

### Environment Variables

All sensitive variables should be set as environment variables (in `.env` file) and loaded before running Terraform or Ansible commands.

Key variables:

- `TF_VAR_do_token` - Digital Ocean API token
- `TF_VAR_spaces_access_id` - Spaces access key ID
- `TF_VAR_spaces_secret_key` - Spaces secret key
- `TF_VAR_ssh_public_key` - SSH public key for server access
- Database credentials, JWT secrets, API keys, etc.

See [GETTING_STARTED.md](./GETTING_STARTED.md) for the complete list.

### Working with Environments

**Development**:

```bash
cd terraform/envs/dev
terraform init
terraform plan
terraform apply
```

**Production**:

```bash
cd terraform/envs/prod
terraform init
terraform plan
terraform apply
```

⚠️ **Warning**: Production deployments require explicit confirmation in the Makefile.

## Architecture

The infrastructure consists of:

- **VPC**: Private network for all resources
- **Droplets**:
  - 1 Manager node (Docker Swarm manager)
  - 1-2 Worker nodes (Docker Swarm workers)
- **Firewalls**:
  - Web firewall (HTTP/HTTPS)
  - Internal firewall (internal communication)
  - Management firewall (SSH access)
- **Spaces**: Object storage for backups and Terraform state
- **Docker Swarm**: Container orchestration
- **Traefik**: Reverse proxy and load balancer
- **PostgreSQL**: Database with pgvector extension
- **Redis**: Caching and message broker

## Documentation

- **[GETTING_STARTED.md](./GETTING_STARTED.md)**: Complete step-by-step deployment guide
- **[terraform/README.md](./terraform/README.md)**: Terraform-specific documentation
- **[ansible/README.md](./ansible/README.md)**: Ansible-specific documentation
- **[terraform/envs/dev/README.md](./terraform/envs/dev/README.md)**: Development environment details
- **[terraform/envs/prod/README.md](./terraform/envs/prod/README.md)**: Production environment details

## Security

- All sensitive variables are marked with `sensitive = true` in Terraform
- Terraform state is stored in an encrypted Spaces bucket
- Never commit `terraform.tfvars` files with real values
- SSH access can be restricted by IP in production
- Use strong passwords and rotate secrets regularly

## Troubleshooting

Common issues and solutions:

- **Terraform backend initialization failed**: Check Spaces credentials and bucket existence
- **Ansible cannot connect**: Wait for cloud-init to complete, verify SSH key
- **Docker secrets already exist**: Normal on re-deployment, remove manually if needed
- **Service won't start**: Check logs with `docker service logs <service-name>`

For more troubleshooting tips, see [GETTING_STARTED.md](./GETTING_STARTED.md#troubleshooting).

## Contributing

1. Make changes to Terraform modules or Ansible playbooks
2. Test in development environment first
3. Update documentation if needed
4. Submit pull request

## License

See [LICENSE](./LICENSE) file for details.
