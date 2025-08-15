function edit --wraps=$EDITOR
    # I commonly tab flake because it's always accompanied by flake.lock
    if test "$argv[1]" = "flake."
        $EDITOR flake.nix
        return 0
    end
    $EDITOR $argv
end
