locals {
  defaults = {
    location    = "hel1"
    server_type = "cax11"
    labels      = {
      arch = "x86_64-linux"
    }
  }
  servers = {
    hetzner1 = {
      enabled = true
      server_type = "cax11"
      vol_size    = 40
      priv_ip     = "10.137.1.1"
      labels = {
        k8s_role = "server"
        arch = "aarch64-linux"
      }
    }
    hetzner2 = {
      enabled = false
      server_type = "cax11"
      vol_size    = 40
      priv_ip     = "10.137.1.2"
      labels = {
        k8s_role = "agent"
        arch = "aarch64-linux"
      }
    }
  }
  servers_filtered = { for k,v in local.servers: k => v if try(v.enabled, false) }
}

resource "hcloud_server" "defconf" {
  for_each = local.servers_filtered

  name        = each.key
  image       = "debian-12"
  server_type = try(each.value.server_type, local.defaults.server_type)
  location    = try(each.value.location, local.defaults.location)
  labels      = merge(local.defaults.labels, try(each.value.labels, local.defaults.labels))

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
  for_each = local.servers_filtered
  name     = each.key
  size     = each.value.vol_size
  location = try(each.value.location, local.defaults.location)
}

resource "hcloud_volume_attachment" "defconf" {
  for_each  = local.servers_filtered
  volume_id = hcloud_volume.defconf[each.key].id
  server_id = hcloud_server.defconf[each.key].id
  automount = false
}

locals {
  servers_out = {
    for k, _ in local.servers_filtered : k => {
      ipv4_address = hcloud_server.defconf[k].ipv4_address
      ipv6_address = hcloud_server.defconf[k].ipv6_address
      labels       = hcloud_server.defconf[k].labels
    }
  }
}

module "install" {
  for_each    = local.servers_out
  source      = "github.com/nix-community/nixos-anywhere//terraform/install"
  instance_id = hcloud_server.defconf[each.key].id
  flake       = "${var.FLAKE}#${each.key}-anywhere"
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
