#! /usr/bin/env fish
while true;
  date | tee -a /tmp/vram.log;
  nix run "nixpkgs#amdgpu_top" -- -d | rg "^VRAM.*usage" -A 3 | tee -a /tmp/vram.log;
  sleep 5;
end
