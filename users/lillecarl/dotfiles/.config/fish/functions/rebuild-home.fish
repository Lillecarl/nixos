function rebuild-home
    set tempdir "$(mktemp -d -t nix-rebuild-home_XXXX)"
    set result "$tempdir/result"
    set buildlog "$tempdir/buildlog.jsonish"
    set evalfile $FLAKE
    set attrpath "homeConfigurations.\"$USER@$hostname\".activationPackage"
    # set fullflake "$FLAKE#homeConfigurations.\"$USER@$hostname\".activationPackage"
    set profile $HOME/.local/state/nix/profiles/home-manager

    set -x HOME_MANAGER_BACKUP_EXT "$bak$(openssl rand -hex 2)"

    echo "Building $evalfile $attrpath"
    echo "Into $result"
    echo "With log $buildlog"

    command nix \
        build \
        --file $evalfile \
        $attrpath \
        --out-link $result \
        --impure \
        $XTRABUILDARGS &| tee $buildlog &| nom --json || begin
        echo "Failed to build $evalfile $attrpath"
        return 1
    end

    nvd diff $profile $result

    echo -n "Activating in: "
    for i in (seq 3 -1 1)
        echo -n "$i "
        sleep 1
    end
    echo

    # home-manager links the profile itself.
    echo "Activating package $result/activate"
    $result/activate || begin
        echo "Failed to activate profile"
        return 1
    end

    rm -rf $tempdir
end
