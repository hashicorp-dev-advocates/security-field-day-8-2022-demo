terraform {
  cloud {
    organization = "hashicorp-team-da-beta"

    workspaces {
      name = "security-field-day-2022"
    }
  }
}