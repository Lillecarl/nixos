function __zi_drop
    if is_kitty -ne 0
        set pre_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
    end

    zi

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
end
