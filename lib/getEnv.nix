name:
let
  value = builtins.getEnv name;
  length = builtins.stringLength value;
in
if length == 0 then
  builtins.throw "Environment variable ${name} requested but is 0 length which Nix treats the same as unset"
else
  value
