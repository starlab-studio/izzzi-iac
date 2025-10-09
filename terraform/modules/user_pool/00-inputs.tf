variable "name" {
  type        = string
  description = "Name of the user pool."
}

variable "region" {
  type        = string
  description = "Region where this resource will be managed."
  default     = "eu-west-3"
}

variable "account_recovery_setting" {
  type = list(object({
    name     = string,
    priority = number
  }))

  default = [
    {
      name     = "verified_email",
      priority = 2
    },
    {
      name     = "verified_phone_number",
      priority = 1
    },
  ]
}

variable "email_sending_account" {
  type        = string
  description = "Email sending account for Cognito"
  default     = "COGNITO_DEFAULT"
}

variable "minimum_length" {
  type        = number
  description = "Minimum length of the password policy that you have set."
  default     = 12
}

variable "password_history_size" {
  type        = number
  description = "Number of previous passwords that you want Amazon Cognito to restrict each user from reusing."
  default     = 10
}

variable "require_lowercase" {
  type        = bool
  description = "Whether you have required users to use at least one lowercase letter in their password."
  default     = true
}

variable "require_numbers" {
  type        = bool
  description = "Whether you have required users to use at least one number in their password."
  default     = true
}

variable "require_symbols" {
  type        = bool
  description = "Whether you have required users to use at least one symbol in their password."
  default     = true
}

variable "require_uppercase" {
  type        = bool
  description = "Whether you have required users to use at least one uppercase letter in their password."
  default     = true
}

variable "allowed_first_auth_factors" {
  type        = string
  description = "The sign in methods your user pool supports as the first factor."
  default     = "PASSWORD"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "auto_verified_attributes" {
  type        = list(string)
  description = "The attributes to be auto-verified."
  default     = ["email"]
}

variable "username_attributes" {
  type        = list(string)
  description = "Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up."
  default     = ["email"]
}

variable "mfa_configuration" {
  type        = string
  description = "Set to enable multi-factor authentication."
  default     = "OFF"
}

variable "allow_admin_create_user_only" {
  type        = bool
  description = "Wether only the administrator is allowed to create user profiles"
  default     = false
}

variable "invite_message_template" {
  type = object({
    email_message = string
    email_subject = string
    sms_message   = string
  })
  default = {
    email_message = "Bonjour {username}, vous avez été invité à rejoindre notre application. Votre mot de passe temporaire est {####}"
    email_subject = "Invitation à rejoindre notre application"
    sms_message   = "Votre identifiant est {username} et votre mot de passe temporaire : {####}"
  }
}

variable "verification_message_template" {
  type = object({
    default_email_option = string
    email_subject        = string
    email_message        = string
  })
  default = {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Bienvenue chez IZZZI"
    email_message        = "Nous vous souhaitons la bienvenue chez IZZZI, la meilleure plateforme de collecte des retours étudiant en live. Pour activer votre compte, veuillez saisir le code confirmation suivant : {####}. L'équie IZZZI"
  }
}


# aws_cognito_user_pool_client

variable "generate_secret" {
  type        = bool
  description = "Boolean flag indicating whether an application secret should be generated."
  default     = true
}

variable "prevent_user_existence_errors" {
  type        = string
  description = "Setting determines the errors and responses returned by Cognito APIs when a user does not exist in the user pool during authentication, account confirmation, and password recovery."
  default     = "ENABLED"
}

variable "enable_token_revocation" {
  type        = bool
  description = "Enables or disables token revocation."
  default     = true
}

variable "enable_propagate_additional_user_context_data" {
  type        = bool
  description = "Enables the propagation of additional user context data."
  default     = true
}

variable "access_token_validity" {
  type        = number
  description = "Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used."
  default     = 60
}

variable "id_token_validity" {
  type        = number
  description = "Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used."
  default     = 60
}

variable "refresh_token_validity" {
  type        = number
  description = "Time limit, between 60 minutes and 10 years, after which the refresh token is no longer valid and cannot be used."
  default     = 60
}

variable "token_validity_units" {
  description = "Unités de validité des tokens Cognito"
  type = object({
    access_token  = string
    id_token      = string
    refresh_token = string
  })
  default = {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

variable "explicit_auth_flows" {
  type        = list(string)
  description = "List of authentication flows."
  default = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
}

variable "allowed_oauth_flows" {
  type        = list(string)
  description = "List of allowed OAuth flows"
  default     = ["code"]
}

variable "allowed_oauth_scopes" {
  type        = list(string)
  description = "List of allowed OAuth scopes."
  default = [
    "email",
    "openid",
    "profile"
  ]
}

variable "allowed_oauth_flows_user_pool_client" {
  type        = bool
  description = "Whether the client is allowed to use OAuth 2.0 features."
  default     = true
}

variable "callback_urls" {
  type        = list(string)
  description = "List of allowed callback URLs for the identity providers."
  default     = ["https://localhost:3000/callback"]
}

variable "logout_urls" {
  type        = list(string)
  description = "List of allowed logout URLs for the identity providers."
  default     = ["https://localhost:3000/logout"]
}

variable "default_redirect_uri" {
  type        = string
  description = "Default redirect URI for OAuth2 flows."
  default     = "https://localhost:3000/callback"
}

variable "supported_identity_providers" {
  type        = list(string)
  description = "List of provider names for the identity providers that are supported on this client."
  default = [
    "COGNITO",
    "Google"
  ]
}

variable "identity_providers" {
  description = "List of user identity providers (Google, Facebook, etc.)"
  type = map(object({
    provider_type     = string
    provider_details  = map(string)
    attribute_mapping = optional(map(string))
  }))
  default = {}
}
