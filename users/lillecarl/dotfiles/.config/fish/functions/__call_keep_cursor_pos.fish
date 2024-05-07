function __call_keep_cursor_pos
    if is_kitty
        set pre_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
    end

    eval $argv[1]

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
