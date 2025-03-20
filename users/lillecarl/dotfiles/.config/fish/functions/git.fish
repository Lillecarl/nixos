function git --wraps=git
    set command $argv[1]
    set args $argv
    set --erase args[1]

    if test $command = push
        command git push $args
        command git remote | rg -q forgejo && git push forgejo $args
    else if test $command = something
        command git something $args
    else
        command git $argv
    end
end
