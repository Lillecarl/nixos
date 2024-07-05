variable "zone_id" {}
variable "mx" {}

resource "cloudflare_record" "mx" {
  zone_id = var.zone_id
  name    = "@"
  type    = "MX"

  data {
    priority = 0
    target   = var.mx
  }
}
