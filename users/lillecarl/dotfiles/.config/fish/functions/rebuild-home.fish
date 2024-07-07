function rebuild-home
    set tempdir "$(mktemp -d -t nix-rebuild-home_XXXX)"
    set result "$tempdir/result"
    set buildlog "$tempdir/buildlog.jsonish"
    set fullflake "$FLAKE#homeConfigurations.\"$USER@$hostname\".activationPackage"
    set profile $HOME/.local/state/nix/profiles/home-manager

    set -x HOME_MANAGER_BACKUP_EXT backup

    echo "Building $fullflake"
    echo "Into $result"
    SHELL=/bin/sh nom \
        build \
        $fullflake \
        --out-link $result \
        $XTRABUILDARGS || begin
        echo "Failed to build $fullflake"
        return 1
    end

    nvd diff $profile $result

    rm $HOME/.mozilla/firefox/lillecarl/containers.json.backup &>/dev/null

    # home-manager links the profile itself.
    echo "Activating package $result/activate"
    $result/activate || begin
        echo "Failed to activate profile"
        return 1
    end

    rm -rf $tempdir
end
