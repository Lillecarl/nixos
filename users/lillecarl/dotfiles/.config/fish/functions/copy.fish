function copy
    set content ""
    if isatty stdin
        # stdin is a tty, use arguments instead of stdin for content
        set content $argv
        set encoded (echo -n "$content" | base64)
    else
        # stdin is not a tty, read stdin into $content with the "read" function
        read --null --silent --list content
        set encoded (echo -n $content | base64)
    end

    # Try using wl-copy to set clipboard through wayland, return early if
    # wl-copy succeeds
    if echo -n "$content" | wl-copy 2>/dev/null
        return
    end

    # Print OSC52 to set clipboard (hopefully)
    echo -e "\033]52;c;$encoded\a"
end
