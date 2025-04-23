function nix --wraps nix
    # Extract nix subcommand
    set command $argv[1]
    set --erase argv[1]

    if test $command = build
        command nix build --no-link --print-out-paths --impure $argv
    else if test $command = repl && test -z "$argv"
        command nix repl --file $FLAKE
    else if test $command = run
        command nix run --impure $argv
    else
        command nix $command $argv
    end
end
