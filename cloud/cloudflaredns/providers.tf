terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.49.1"
    }
  }
}

provider "cloudflare" {
  # Configuration options
}
