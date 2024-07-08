set -x fish_greeting ""
set -x SHELL fish
set -x DIRENV_LOG_FORMAT ""
set -x TZ Europe/Stockholm
set -x MYDATE "+%y-%m-%d %H:%M:%S"

fish_vi_key_bindings

# trigger direnv before prompt is rendered
set -g direnv_fish_mode eval_on_arrow

set -x KREW_ROOT "$XDG_CONFIG_HOME/krew"
set -a PATH $KREW_ROOT/bin

alias grt="cd (git root)"
alias tg=terragrunt
alias pager=$PAGER
alias kc=kubectl

abbr -a :q exit

abbr -a sc sudo systemctl
abbr -a ssc sudo systemctl
abbr -a scu systemctl --user

abbr -a jc journalctl -u
abbr -a jcu journalctl --user-unit
abbr -a jci journalinvocation -u
abbr -a jcui journalinvocation --user-unit

abbr -a ssha ssh -oForwardAgent=yes
abbr -a sshr ssh-keygen -R

abbr -a gpa git pull --all --recurse-submodules
abbr -a gfa git fetch --all --recurse-submodules
abbr -a grm git rebase origin/main
abbr -a gsu git submodule update --recursive
abbr -a gsgp "git switch main && git pull"

abbr -a rb rebuild-both
abbr -a ro rebuild-os
abbr -a rh rebuild-home

# Run previous command with sudo
abbr -a !! -f histsudo

set -x FISH_PID $fish_pid

function sshloop1
    set -l user $argv[1]
    set -l host $argv[2]
    while true
        sleep 1
        set -l time (date +%s)
        ssh-keygen -R $host >/dev/null 2>&1
        kitten ssh $user@$host
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
        kitten ssh $user@$host
    end
end
