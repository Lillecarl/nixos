set -x fish_greeting ""
set -x SHELL "fish"
fish_vi_key_bindings

function git_root
  cd "$(git rev-parse --show-toplevel)"
end
alias grt git_root

function get_git_root
  git rev-parse --show-toplevel
end
alias ggrt get_git_root

if set -q LASTPATH; and not set -q TMUX;
  cd $LASTPATH
end

abbr -a sc sudo systemctl
abbr -a ssc sudo systemctl
abbr -a scu systemctl --user
abbr -a jc journalctl -u
abbr -a jcu journalctl --user-unit
abbr -a jci journalinvocation -u
abbr -a jcui journalinvocation --user-unit
abbr -a ssha ssh -oForwardAgent=yes
abbr -a sshr ssh-keygen -R
abbr -a ls eza
abbr -a ll eza -lah
abbr -a cat bat --paging=never

# bind ctrl+a to beginning of buffer
bind \ca -M insert beginning-of-buffer
# bind ctrl+e to end of buffer
bind \ce -M insert end-of-buffer

# function that is called on fish_preexec event (before executing something)
function reload_awscreds -e fish_preexec;
  # If we don't have aws credential expiration or direnv we do nothing
  if not set -q AWS_CREDENTIAL_EXPIRATION || not set -q DIRENV_FILE;
    return
  end

  # Get current date in the same weird format AWS uses
  set CURDATE $(date -u +%Y-%m-%dT%H:%M:%SZ)
  # Convert our date to unixtime
  set CURSEC $(date '+%s' -d $CURDATE)
  # Convert AWS date to unixtime
  set AWSSEC $(date '+%s' -d $AWS_CREDENTIAL_EXPIRATION)

  # If we have less than 30 minutes left of credentials, reload with direnv
  if [ $(math $AWSSEC - $CURSEC) -le 1800 ];
    direnv reload
  end
end

function set_lastpath -e fish_postexec;
  if not set -q TMUX;
    set -U LASTPATH $PWD;
  end;
end;

function wezvim;
  wezterm cli get-text | nvim \
    -c "set buftype=nofile" \
    -c '$' \
    -c '-3' \
    -c 'delete 3'
end;
