function hcp
    if is_kitty
        set pre_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
    end

    set result (atuin search -i 3>&1 1>&2 2>&3 | string collect)
    echo $result | copy

    if is_kitty
        set post_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
        set drop (math $post_height - $pre_height)
    end

    if is_kitty && test $drop -gt 0
        set drop (math $drop - 2)
        echo -en '\e['$drop'+T'
        echo -en '\e['$drop'B'
    end

    commandline -f repaint
end
