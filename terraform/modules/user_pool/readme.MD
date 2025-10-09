# AWS Cognito User Pool Module

This module creates an AWS Cognito User Pool with a user pool client for authentication.

## Features

- User pool with configurable password policy
- Account recovery settings
- Email verification
- MFA support (configurable)
- User pool client with OAuth flows
- Advanced security mode enabled
- Configurable tags

## Usage

```hcl
module "user_pool" {
  source = "../../modules/user_pool"

  name = "my-app-user-pool"
  region = "eu-west-3"

  # Password policy
  minimum_length = 12
  require_lowercase = true
  require_numbers = true
  require_symbols = true
  require_uppercase = true

  # MFA
  mfa_configuration = "OPTIONAL"

  # Tags
  tags = {
    Environment = "prod"
    Project     = "my-app"
  }
}
```

## Inputs

| Name                  | Description                                 | Type          | Default             | Required |
| --------------------- | ------------------------------------------- | ------------- | ------------------- | :------: |
| name                  | Name of the user pool                       | `string`      | n/a                 |   yes    |
| region                | Region where this resource will be managed  | `string`      | `"eu-west-3"`       |    no    |
| email_sending_account | Email sending account for Cognito           | `string`      | `"COGNITO_DEFAULT"` |    no    |
| minimum_length        | Minimum length of the password policy       | `number`      | `12`                |    no    |
| require_lowercase     | Require lowercase letters in password       | `bool`        | `true`              |    no    |
| require_numbers       | Require numbers in password                 | `bool`        | `true`              |    no    |
| require_symbols       | Require symbols in password                 | `bool`        | `true`              |    no    |
| require_uppercase     | Require uppercase letters in password       | `bool`        | `true`              |    no    |
| mfa_configuration     | MFA configuration                           | `string`      | `"OFF"`             |    no    |
| tags                  | A mapping of tags to assign to the resource | `map(string)` | `{}`                |    no    |

## Outputs

| Name                    | Description                               |
| ----------------------- | ----------------------------------------- |
| user_pool_id            | The ID of the user pool                   |
| user_pool_arn           | The ARN of the user pool                  |
| user_pool_endpoint      | The endpoint name of the user pool        |
| user_pool_client_id     | The ID of the user pool client            |
| user_pool_client_secret | The client secret of the user pool client |
| user_pool_domain        | The domain of the user pool               |
