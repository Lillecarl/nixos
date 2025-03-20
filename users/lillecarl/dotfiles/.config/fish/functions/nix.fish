function nix --wraps nix
    set command $argv[1]
    set args $argv
    set --erase args[1]

    if test $command = build
        command nix build $args --no-link --print-out-paths --impure
    else if test $command = repl
        command nix repl --file $FLAKE
    else if test $command = run
        command nix run $args --impure
    else
        command nix $argv
    end
end
