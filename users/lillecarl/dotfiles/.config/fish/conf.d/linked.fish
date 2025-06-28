set --export fish_greeting ""
set --export DIRENV_LOG_FORMAT ""
set --export TZ Europe/Stockholm
set --export MYDATE "+%y-%m-%d %H:%M:%S"
set --export HOST $hostname
set --export NERDFONTS

# Set DISPLAY if we have an X11 socket to use
if test -S /tmp/.X11-unix/X0
    set --export DISPLAY :0
end

fish_vi_key_bindings

# trigger direnv before prompt is rendered
set -g direnv_fish_mode eval_on_arrow

abbr -a :q exit

abbr -a kc kubectl
abbr -a kns kubens
abbr -a knd kubens default
abbr -a tg terragrunt
abbr -a tgp terragrunt plan
abbr -a tga terragrunt apply
abbr -a tgaa terragrunt apply -auto-approve

abbr -a grt 'cd (git root)'

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

# Don't show client popups in fish LSP
set -gx fish_lsp_show_client_popups false

# ctrl+l fish completes
bind -M insert \f forward-char
