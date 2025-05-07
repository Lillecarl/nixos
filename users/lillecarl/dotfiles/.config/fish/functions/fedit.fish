function fedit --wraps fd
    function __sk
        sk -m --preview "bat --color=always {}"
    end

    if test -z "$argv[1]"
        set editfile (fd -t f | __sk)
    else
        set editfile (fd -t f $argv | __sk)
    end

    if test -n "$editfile"
        commandline -r "$EDITOR $editfile"
        commandline -f repaint
        commandline -f execute
    else
        echo "No file selected"
    end

    functions --erase __sk
end
