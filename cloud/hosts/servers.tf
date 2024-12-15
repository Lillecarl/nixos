locals {
  defaults = {
    location    = "hel1"
    server_type = "cax11"
  }
  servers = {
    hetzner1 = {
      server_type = "cax11"
      vol_size    = 40
      priv_ip     = "10.137.1.1"
    }
    hetzner2 = {
      server_type = "cax11"
      vol_size    = 40
      priv_ip     = "10.137.1.2"
    }
  }
}

resource "hcloud_server" "defconf" {
  for_each = local.servers

  name        = each.key
  image       = "debian-12"
  server_type = try(each.value.server_type, local.defaults.server_type)
  location    = try(each.value.location, local.defaults.location)

  ssh_keys = [
    hcloud_ssh_key.main.id
  ]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.this.id
    ip         = each.value.priv_ip
    alias_ips  = []
  }
  depends_on = [
    hcloud_network_subnet.this
  ]
}

resource "hcloud_volume" "defconf" {
  for_each = local.servers
  name     = each.key
  size     = each.value.vol_size
  location = try(each.value.location, local.defaults.location)
}

resource "hcloud_volume_attachment" "defconf" {
  for_each  = local.servers
  volume_id = hcloud_volume.defconf[each.key].id
  server_id = hcloud_server.defconf[each.key].id
  automount = false
}

locals {
  servers_out = {
    for k, _ in local.servers : k => {
      ipv4_address = hcloud_server.defconf[k].ipv4_address
      ipv6_address = hcloud_server.defconf[k].ipv6_address
    }
  }
}

module "install" {
  for_each    = local.servers_out
  source      = "github.com/nix-community/nixos-anywhere//terraform/install"
  instance_id = hcloud_server.defconf[each.key].id
  flake       = "${var.FLAKE}#${each.key}"
  target_host = each.value.ipv4_address
  depends_on = [
    hcloud_server.defconf,
    local_file.hosts_json,
  ]
}

# Configured by direnv
variable "FLAKE" {}
# Dump host names and IP addresses into a JSON to be consumed by a Nix 
# deployment tool (currently deploy-rs).
resource "local_file" "hosts_json" {
  content  = jsonencode(local.servers_out)
  filename = "${var.FLAKE}/hosts/hetzner/hosts.json"
}
