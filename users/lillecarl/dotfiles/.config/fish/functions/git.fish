function git --wraps=git
    set command $argv[1]
    set --erase argv[1]

    if test $command = push && test -z "$argv"
        command git push $argv

        if command git remote | rg -q forgejo
            command git push forgejo $argv
        end
    else
        command git $command $argv
    end
end
