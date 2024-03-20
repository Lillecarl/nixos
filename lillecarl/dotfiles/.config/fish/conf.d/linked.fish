set -x fish_greeting ""
set -x SHELL fish
set -x DIRENV_LOG_FORMAT ""
fish_vi_key_bindings

# trigger direnv before prompt is rendered
set -g direnv_fish_mode eval_on_arrow

if set -q LASTPATH
    and not set -q TMUX
    and not set -q VSCODE_INJECTION
    begin
        cd $LASTPATH
    end
end

alias cat="bat --paging=never"
alias grt="cd (git root)"
alias tg=terragrunt
alias pager=$PAGER

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

abbr -a nos nh os switch -- --impure
abbr -a nhs nh home switch -- --impure
abbr -a nro nix-rebuild os
abbr -a nrh nix-rebuild home

# bind ctrl+a to beginning of buffer
bind -M insert \ca beginning-of-buffer
bind -M visual \ca beginning-of-buffer
# bind ctrl+e to end of buffer
bind -M insert \ce end-of-buffer
bind -M visual \ce end-of-buffer
# bind alt+l to complete whatever fish is suggesting
bind -M insert \el forward-char
# bind ctrl+shift+e to edit command buffer
bind -M insert \e\[101\;6u edit_command_buffer
bind -M visual \e\[101\;6u edit_command_buffer
# bind /
bind -M visual / _atuin_search
# bind ctrl+shift+d to scroll down
bind -M insert \e\[100\;6u scrolldown
bind -M visual \e\[100\;6u scrolldown

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
