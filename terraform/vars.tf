variable "rg_name" {
  type        = string
  default     = "security-field-day"
  description = "Name of resource group"
}

variable "rg_location" {
  type        = string
  default     = "West Europe"
  description = "location of resource group"
}

variable "tls_ca_subject" {
  description = "The `subject` block for the root CA certificate."
  type = object({
    common_name         = string,
    organization        = string,
    organizational_unit = string,
    street_address      = list(string),
    locality            = string,
    province            = string,
    country             = string,
    postal_code         = string,
  })

  default = {
    common_name         = "Example Inc. Root"
    organization        = "Example, Inc"
    organizational_unit = "Department of Certificate Authority"
    street_address      = ["123 Example Street"]
    locality            = "The Intranet"
    province            = "CA"
    country             = "US"
    postal_code         = "95559-1227"
  }
}

variable "tls_dns_names" {
  description = "List of DNS names added to the self-signed certificate. E.g vault.example.net"
  type        = list(string)
  default     = []
}

variable "ip_addresses" {
  type        = list(string)
  default     = []
  description = "List of IP addresses to add to the certificate."
}

variable "tls_cn" {
  description = "The TLS Common Name for the TLS certificates"
  default     = "certificate.example.net"
}

variable "boundary_cluster_id" {
  type = string
}

variable "boundary_addr" {
  type        = string
  description = "the url of the Boundary controller"
}

variable "boundary_auth_method_id" {
  type        = string
  description = "Auth method ID to which Terraform will authenticate"
}

variable "boundary_org_auth_method_id" {
  type = string
}

variable "boundary_login_name" {
  type = string
}

variable "boundary_login_password" {
  type = string
}

variable "boundary_org_id" {
  type = string
}

variable "boundary_project_id" {
  type = string
}

variable "hcp_client_id" {
  type = string
}

variable "hcp_client_secret" {
  type = string
}

variable "vault_addr" {
  type = string
}

variable "vault_token" {
  type = string
}

variable "target_username" {
  type = string
}

variable "target_password" {
  type = string
}