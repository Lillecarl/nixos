resource "random_password" "noreply" {
  length           = 16
  special          = true
  override_special = "!#."

}
resource "migadu_mailbox" "noreply" {
  name        = "noreply"
  domain_name = "lillecarl.com"
  local_part  = "noreply"
  password    = random_password.noreply.result

  may_receive             = false
  may_access_imap         = false
  may_access_manage_sieve = false
  may_access_pop3         = false
}
output "smtp_info" {
  sensitive = true
  value = {
    host = "smtp.migadu.com"
    user = migadu_mailbox.noreply.address
    pass = random_password.noreply.result
    port = 465
  }
}
