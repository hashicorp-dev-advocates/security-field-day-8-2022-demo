resource "tls_private_key" "root_ca_key" {

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "root_ca_cert" {

#  key_algorithm   = tls_private_key.root_ca_key.algorithm
  private_key_pem = tls_private_key.root_ca_key.private_key_pem

  subject {
    common_name         = var.tls_ca_subject.common_name
    country             = var.tls_ca_subject.country
    locality            = var.tls_ca_subject.locality
    organization        = var.tls_ca_subject.organization
    organizational_unit = var.tls_ca_subject.organizational_unit
    postal_code         = var.tls_ca_subject.postal_code
    province            = var.tls_ca_subject.province
    street_address      = var.tls_ca_subject.street_address
  }

  validity_period_hours = 26280
  early_renewal_hours   = 8760
  is_ca_certificate     = true

  allowed_uses = ["cert_signing"]
}

variable "tls_ou" {
  description = "The TLS Organizational Unit for the TLS certificate"
  default     = "HashiCorp Developer Advocates"
}

resource "tls_private_key" "private_key" {

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "csr" {

#  key_algorithm   = tls_private_key.private_key.algorithm
  private_key_pem = tls_private_key.private_key.private_key_pem

  dns_names = var.tls_dns_names

  ip_addresses = var.ip_addresses

  subject {
    common_name         = var.tls_cn
    organization        = var.tls_ca_subject["organization"]
    organizational_unit = var.tls_ou
  }
}

resource "tls_locally_signed_cert" "cert" {

  cert_request_pem   = tls_cert_request.csr.cert_request_pem
#  ca_key_algorithm   = tls_private_key.root_ca_key.algorithm
  ca_private_key_pem = tls_private_key.root_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca_cert.cert_pem

  validity_period_hours = 17520
  early_renewal_hours   = 8760

  allowed_uses = ["server_auth"]
}


