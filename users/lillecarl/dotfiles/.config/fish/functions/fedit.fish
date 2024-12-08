function fhx
    set editfile (fd -t f --full-path $argv | sk -m --preview "bat --color=always {}")

    if test -n "$editfile"
        commandline -r "$EDITOR $editfile"
        commandline -f repaint
        commandline -f execute
    else
        echo "No file selected"
    end
end
