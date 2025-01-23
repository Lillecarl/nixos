{ ... }:
{
  terraform.required_providers = {
    bitwarden = {
      source = "maxlaverse/bitwarden";
    };
    cloudflare = {
      source = "cloudflare/cloudflare";
    };
    grafana = {
      source = "grafana/grafana";
    };
    htpasswd = {
      source = "loafoe/htpasswd";
    };
    http = {
      source = "hashicorp/http";
    };
    keycloak = {
      source = "keycloak/keycloak";
    };
    kubectl = {
      source = "alekc/kubectl";
    };
    kubernetes = {
      source = "hashicorp/kubernetes";
    };
    kustomization = {
      source = "kbst/kustomization";
    };
    local = {
      source = "hashicorp/local";
    };
    migadu = {
      source = "metio/migadu";
    };
    postgresql = {
      source = "cyrilgdn/postgresql";
    };
    random = {
      source = "hashicorp/random";
    };
    string-functions = {
      source = "random-things/string-functions";
    };
    vault = {
      source = "hashicorp/vault";
    };
    jwks = {
      source = "iwarapter/jwks";
    };
  };
}
