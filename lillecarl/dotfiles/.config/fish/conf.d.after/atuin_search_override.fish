# Defined via `source`
function _atuin_search
    set is_kitty (test $TERM == "xterm-kitty")
    if $is_kitty
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

    if $is_kitty
        set post_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
        set drop (math $post_height - $pre_height)
    end

    if test $drop -gt 0 && $is_kitty
        # This scrolls the commandline to the bottom after an atuin search
        printf %b '\e[$'$drop'+T' $drop
        printf %b '\e[$'$drop'B' $drop
    end
    commandline -f repaint
end
