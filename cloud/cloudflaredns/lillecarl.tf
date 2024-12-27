data "cloudflare_zone" "lillecarl" {
  name = "lillecarl.com"
}

resource "cloudflare_record" "autoconfig" {
  zone_id = data.cloudflare_zone.lillecarl.id

  type    = "CNAME"
  name    = "autoconfig"
  content = "autoconfig.migadu.com"
  comment = "Thunderbird style email autoconfig"
  proxied = false
  ttl     = 1
}
resource "cloudflare_record" "migadu-dkim" {
  count   = 3
  zone_id = data.cloudflare_zone.lillecarl.id

  type    = "CNAME"
  name    = "key${count.index}._domainkey"
  content = "key${count.index}.lillecarl.com._domainkey.migadu.com"
  comment = "Migadu DKIM signing key"
  proxied = false
  ttl     = 1
}
