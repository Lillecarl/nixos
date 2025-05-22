function nix --wraps nix
    # Extract nix subcommand
    set command $argv[1]
    set argvClone $argv
    set --erase argv[1]

    set --export NIX_CONFIG "access-tokens = github.com=$(echo $PS_GHBASIC | base64 -d)"

    if test $command = build
        command nix build --no-link --print-out-paths --impure $argv
    else if test $command = repl && test -z "$argv"
        command nix repl --file $FLAKE
    else if test $command = run
        command nix run --impure $argv
    else if test $command = getrev
        set input nixpkgs
        if test -n "$argv[1]"
            set input $argv[1]
        end
        command nix eval --expr "(import $FLAKE).inputs.$input.rev" --impure --raw
    else
        command nix $command $argv
    end
end
