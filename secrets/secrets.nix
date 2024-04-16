let
  lillecarl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwiL9rEa5vSKnD3yXn+GLuJY0NwWq6CYTYM759TK+80 lillecarl@agenix";
  users = [ lillecarl ];

  nub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6+IWwqGjVoXHcNR5Z5H2r7RYDQ0BzvPbl/RXeDnidv root@nub";
  shitbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUmhT3THV21iW0N8L8jx0DhOMkVHcJGF6I5tXeeBx6F root@shitbox";
  systems = [ nub shitbox ];
in
{
  "cloudflare.age".publicKeys = users ++ systems;
}
