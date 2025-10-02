# IZZZI AWS Architecture

![Terraform Version](https://img.shields.io/static/v1?label=Terraform&message=1.7.5&color=blue)
![AWS Cli](https://img.shields.io/static/v1?label=Aws-Cli&message=2.15.2&color=orange)
![Ansible Version](https://img.shields.io/static/v1?label=Terraform&message=1.7.5&color=blue)

Hub for creating and managing our required infrastructure for IZZZI apps deployment. Here, you'll find the Terraform configurations
powering our cloud infrastructure, ensuring a robust and scalable implementation of our centralized data environment.
| |

## Requirements

| Tool                                                               | Version | Mandatory | Usage                                                             |
| ------------------------------------------------------------------ | ------- | --------- | ----------------------------------------------------------------- |
| [Terraform](https://terraform.io)                                  | 1.7.5   | Yes       | Used to manage the various projects.                              |
| [terraform-docs](https://github.com/terraform-docs/terraform-docs) | 0.12.1  | No        | Used to generate Terraform documentation.                         |
| [tflint](https://github.com/wata727/tflint)                        | 0.33.0  | No        | Terraform linter focused on possible errors, best practices, etc. |
| [awscli](https://github.com/aws/aws-cli)                           | 2.15.2+ | Yes       | Used to manage AWS resources.                                     |

### Terraform

Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. This includes low-level components like compute instances, storage, and networking; and high-level components like DNS entries and SaaS features.

- [Getting started with Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)
- [Setup Terraform cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### awc-cli

The AWS Command Line Interface (AWS CLI) is an open source tool that enables you to interact with AWS services using commands in your command-line shell. With minimal configuration, the AWS CLI enables you to start running commands that implement functionality equivalent to that provided by the browser-based AWS Management Console from the command prompt in your terminal program.

- [Setup aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Project structure

```

├── envs                                            # Deployment environments
│   ├── dev                                         ## Development environment ressources
│   │   ├── backend.tf                              ### Define which backend to use
│   │   ├── main.tf                                 ### Contains cloud ressources to create
│   │   ├── providers.tf                            ### Contains cloud provider definition
│   │   └── versions.tf                             ### Contains cloud provider version
│   ├── prod                                        # Production environment ressources
├── modules                                         # Terraform reusable modules
│   ├── vpc                                         ## Datalake modules
│   │   ├── 00-inputs.tf                            ### Contains modules variables
│   │   ├── 01-main.tf                              ### Contains terraform modules  definition
│   │   ├── 00-outputs.tf                           ### Contains module outputs
│   │   ├── readme.MD                               ### Module documentation
│   ├── ecr                                         ## Elastic container registry module
├── README.md                                       # The full documentation
```

## How to use this project

### How to login on aws to apply terraform

You must have your aws profile setup, you can find a sample here: `terraform/config`

```
cat terraform/config >> ~/.aws/config
```

Next please login to aws with aws-cli with the profile `izzzi/starlab` to acces to Terraform state

```
aws sso login --profile izzzi/starlab
```

### How to plan or apply a specific environment

Here we apply an environment (echo dev example) in Aws Paris.

```
cd terraform/envs/dev/
terraform init
terraform plan
terraform apply
```
