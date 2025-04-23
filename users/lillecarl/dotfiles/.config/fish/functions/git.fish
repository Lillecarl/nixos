function git --wraps=git
    set command $argv[1]
    set --erase argv[1]

    if test $command = push
        command git push $args

        if command git remote | rg -q forgejo
            command git push forgejo $args
        end
    else
        command git $command $argv
    end
end
