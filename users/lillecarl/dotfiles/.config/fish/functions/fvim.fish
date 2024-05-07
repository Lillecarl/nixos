function fvim
    set vimfile (fd -t f $argv | sk -m --preview "bat --color=always {}")

    if test -n "$vimfile"
        commandline -r "vim $vimfile"
        commandline -f repaint
        commandline -f execute
    else
        echo "No file selected"
    end
end
