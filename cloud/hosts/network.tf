resource "hcloud_network" "this" {
  name     = "bigl2"
  ip_range = "10.137.0.0/16"
}
resource "hcloud_network_subnet" "this" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.137.0.0/16"
}
