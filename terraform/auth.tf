resource "aws_cognito_user_pool" "pool" {
  name                     = "bandoru-users"
  auto_verified_attributes = ["email"]
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  username_attributes = ["email"]
  #deletion_protection = "ACTIVE"
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = false
    require_symbols   = false
  }
  username_configuration {
    case_sensitive = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.cognito-domain
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "default-client" {
  name = "bandoru-client"

  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = ["${aws_apigatewayv2_api.spa-proxy.api_endpoint}/login-success"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = false
  prevent_user_existence_errors        = "ENABLED"
}
