data "cloudflare_zones" "example" {
  filter {
    match = ".*"
  }
}

locals {
  zones = {
    for zone in data.cloudflare_zones.example.zones : zone.name => zone
  }
}

resource "cloudflare_record" "example" {
  for_each = local.zones
  zone_id = each.value.id
  name    = "terraform"
  value   = "192.0.2.1"
  type    = "A"
  ttl     = 3600
}

module "o365" {
  source = "./o365"
  zone_id = local.zones["lillecarl.com"].id
  mx = "lillecarl-com.mail.protection.outlook.com"
}
