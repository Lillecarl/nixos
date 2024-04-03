function rebuild-home
    set tempdir "$(mktemp -d -t nix-rebuild-home_XXXX)"
    set result "$tempdir/result"
    set buildlog "$tempdir/buildlog.jsonish"
    set fullflake "$FLAKE#homeConfigurations.\"$USER@$hostname\".activationPackage"
    set profile $HOME/.local/state/nix/profiles/home-manager

    echo "Building $fullflake"
    echo "Into $result"
    nom \
        build \
        $fullflake \
        --out-link $result || begin
        echo "Failed to build $fullflake"
        return 1
    end

    nvd diff $profile $result

    # home-manager links the profile itself.
    echo "Activating package $result/activate"
    $result/activate
    if test $status != 0
        echo "Failed to activate profile"
        return 1
    end

    # Store editorconfig in /tmp so temporary vim edits follow my rules
    ln -f -s $HOME/.editorconfig /tmp/.editorconfig

    rm -rf $tempdir
end
