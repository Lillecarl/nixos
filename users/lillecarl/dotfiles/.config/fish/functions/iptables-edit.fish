function iptables-edit
    set tfile $(mktemp)
    sudo iptables-save > $tfile
    $EDITOR $tfile

    if set -q SSH_TTY
        sudo iptables-apply < $tfile
    else
        sudo iptables-restore < $tfile
    end
end
