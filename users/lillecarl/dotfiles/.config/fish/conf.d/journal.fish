#! /usr/bin/env fish

complete -c journalinvocation -f

function journalinvocation --wraps="journalctl";
  set invocationid (systemctl show -p InvocationID --value $argv[2])
  set -a argv "_SYSTEMD_INVOCATION_ID=$invocationid"
  echo $argv
  journalctl $argv
end
