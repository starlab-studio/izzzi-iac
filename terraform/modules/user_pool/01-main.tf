resource "aws_cognito_user_pool" "this" {
  name = var.name

  # Account recovery settings
  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.account_recovery_setting
      content {
        name     = recovery_mechanism.value.name
        priority = recovery_mechanism.value.priority
      }
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = var.email_sending_account
  }

  # Password policy
  password_policy {
    minimum_length    = var.minimum_length
    require_lowercase = var.require_lowercase
    require_numbers   = var.require_numbers
    require_symbols   = var.require_symbols
    require_uppercase = var.require_uppercase
  }

  # User pool attributes
  auto_verified_attributes = var.auto_verified_attributes
  username_attributes      = var.username_attributes

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  # Admin create user config
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only

    invite_message_template {
      email_message = var.invite_message_template.email_message
      email_subject = var.invite_message_template.email_subject
      sms_message   = var.invite_message_template.sms_message
    }
  }

  #   Email verification
  verification_message_template {
    default_email_option = var.verification_message_template.default_email_option
    email_subject        = var.verification_message_template.email_subject
    email_message        = var.verification_message_template.email_message
  }

  # User pool add ons
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  # Schema attributes
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type = "String"
    name                = "organization"
    required            = false
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Tags
  tags = var.tags
}

# User Pool Client
resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.name}-client"
  user_pool_id = aws_cognito_user_pool.this.id

  # Client settings
  generate_secret                               = var.generate_secret
  prevent_user_existence_errors                 = var.prevent_user_existence_errors
  enable_token_revocation                       = var.enable_token_revocation
  enable_propagate_additional_user_context_data = var.enable_propagate_additional_user_context_data

  # Token validity
  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = var.token_validity_units.access_token
    id_token      = var.token_validity_units.id_token
    refresh_token = var.token_validity_units.refresh_token
  }

  # Authentication flows
  explicit_auth_flows = var.explicit_auth_flows

  # OAuth settings
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client

  # Callback URLs (to be configured based on your application)
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Supported identity providers
  supported_identity_providers = var.supported_identity_providers

}


# User Identity provider
resource "aws_cognito_identity_provider" "this" {
  for_each = var.identity_providers

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = each.key
  provider_type = each.value.provider_type

  provider_details = each.value.provider_details

  attribute_mapping = lookup(each.value, "attribute_mapping", {
    email = "email"
  })

  lifecycle {
    ignore_changes = [
      provider_details,
      attribute_mapping,
    ]
  }
}
