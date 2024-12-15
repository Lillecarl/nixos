resource "hcloud_ssh_key" "main" {
  name       = "carl-personal"
  public_key = file("~/.ssh/id_ed25519.pub")
}
