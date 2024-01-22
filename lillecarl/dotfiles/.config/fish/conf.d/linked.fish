set -x fish_greeting ""
set -x SHELL fish
fish_vi_key_bindings

# trigger dirent before prompt is rendered
set -g direnv_fish_mode eval_on_arrow

function git_root
    cd "$(git rev-parse --show-toplevel)"
end
alias grt git_root

function get_git_root
    git rev-parse --show-toplevel
end
alias ggrt get_git_root

if set -q LASTPATH
   and not set -q TMUX
   and not set -q VSCODE_INJECTION
  begin
    cd $LASTPATH
  end
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
abbr -a :q exit
abbr -a gpa git pull --all --recurse-submodules
abbr -a gfa git fetch --all --recurse-submodules
abbr -a gsu git submodule update --recursive
abbr -a nos nh os switch -- --impure
abbr -a nhs nh home switch -- --impure

# bind ctrl+a to beginning of buffer
bind \ca -M insert beginning-of-buffer
# bind ctrl+e to end of buffer
bind \ce -M insert end-of-buffer
# bind alt+l to complete whatever fish is suggesting
bind -M insert \el forward-char

# function that is called on fish_preexec event (before executing something)
function reload_awscreds -e fish_preexec
    # If we don't have aws credential expiration or direnv we do nothing
    if not set -q AWS_CREDENTIAL_EXPIRATION || not set -q DIRENV_FILE
        return
    end

    # Get current date in the same weird format AWS uses
    set CURDATE $(date -u +%Y-%m-%dT%H:%M:%SZ)
    # Convert our date to unixtime
    set CURSEC $(date '+%s' -d $CURDATE)
    # Convert AWS date to unixtime
    set AWSSEC $(date '+%s' -d $AWS_CREDENTIAL_EXPIRATION)

    # If we have less than 30 minutes left of credentials, reload with direnv
    if [ $(math $AWSSEC - $CURSEC) -le 1800 ]
        direnv reload
    end
end

function set_lastpath -e fish_postexec
    if not set -q TMUX
        set -U LASTPATH $PWD
    end
end

function sshloop1
    set -l user $argv[1]
    set -l host $argv[2]
    while true
        sleep 1
        set -l time (date +%s)
        ssh-keygen -R $host >/dev/null 2>&1
        ssh $user@$host
        if [ $(math $(date +%s) - $time) -gt 60 ]
            break
        end
    end
end

function sshloop2
    set -l user $argv[1]
    set -l host $argv[2]
    while true
        sleep 1
        ssh-keygen -R $host >/dev/null 2>&1
        ssh $user@$host
    end
end
