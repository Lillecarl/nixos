function pnix
    set command $argv[1]
    set args $argv
    set --erase args[1]

    if test $command = build
        nix build $args --no-link --print-out-paths --impure
    else if test $command = repl
        nix repl --file $FLAKE
    else if test $command = run
        nix run $args --impure
    else
        nix $argv
    end
end
