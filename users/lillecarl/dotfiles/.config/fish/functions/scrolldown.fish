function scrolldown
    set screen_height (kitty @ kitten get_cursor.py | jq '.lines')
    set cursor_height (kitty @ kitten get_cursor.py | jq '.cursor.height')
    set drop (math $cursor_height - 1)
    if test $drop -gt 0
        printf %b '\e[$'$drop'+T'
        printf %b '\e[$'$drop'B'
    end
end
