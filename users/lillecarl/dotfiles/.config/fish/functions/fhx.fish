function fhx
    set hxfile (fd -t f --full-path $argv | sk -m --preview "bat --color=always {}")

    if test -n "$hxfile"
        commandline -r "hx $hxfile"
        commandline -f repaint
        commandline -f execute
    else
        echo "No file selected"
    end
end
