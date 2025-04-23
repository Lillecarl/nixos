function unlink
    argparse c/cp help -- $argv

    if set --query _flag_help
        command unlink --help
        echo
        echo 'NOTE: You can also use -c or --cp to unlink and copy the file to the link location'
        return
    end

    set linkpath $argv[1]

    if ! test -L $linkpath
        echo "Not a symlink"
        return
    end

    if set --query _flag_cp
        echo "Copy unlinking $linkpath"
        set tmpfile (mktemp)
        cp $linkpath $tmpfile
        command unlink $linkpath
        cp $tmpfile $linkpath
        chmod +w $linkpath
        rm $tmpfile
    else
        echo "Unlinking $linkpath"
        command unlink $linkpath
    end
end
