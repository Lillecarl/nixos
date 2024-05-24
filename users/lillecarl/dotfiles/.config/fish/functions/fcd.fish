function fcd
    set sel (fd -t d $argv | sk -m --preview "lsd -lah --color always --date \"$MYDATE\" {}")

    if test -n "$sel"
        commandline -r "cd $sel"
        commandline -f repaint
        commandline -f execute
    else
        echo "No valid selection"
    end
end
