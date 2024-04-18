# Defined via `source`
function is_kitty
    test $TERM = xterm-kitty && return 0 || return 1
end

function _atuin_search
    echo "Atuin search" >&3
    if is_kitty -ne 0
        set pre_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
    end

    set -l ATUIN_H "$(ATUIN_SHELL_FISH=t ATUIN_LOG=error atuin search $argv -i -- (commandline -b) 3>&1 1>&2 2>&3)"

    if test -n "$ATUIN_H"
        if string match --quiet '__atuin_accept__:*' "$ATUIN_H"
            set -l ATUIN_HIST "$(string replace "__atuin_accept__:" "" -- "$ATUIN_H")"
            commandline -r "$ATUIN_HIST"
            commandline -f repaint
            commandline -f execute
            return
        else
            commandline -r "$ATUIN_H"
        end
    end

    if is_kitty
        set post_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
        set drop (math $post_height - $pre_height)
    end

    if is_kitty && test $drop -gt 0
        # This scrolls the commandline to the bottom after an atuin search
        echo "Dropping $drop" >&3
        echo -en '\e['$drop'+T'
        echo -en '\e['$drop'B'
    end
    commandline -f repaint
end
