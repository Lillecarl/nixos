variable "VAULT_ROOT_TOKEN" {}
provider "vault" {
  address = "https://vault.lillecarl.com"
  token   = var.VAULT_ROOT_TOKEN
}
