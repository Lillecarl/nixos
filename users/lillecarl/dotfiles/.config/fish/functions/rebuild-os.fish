function rebuild-os
    sudo echo -n || begin
        echo "Failed to get sudo"
        return 1
    end

    set tempdir "$(mktemp -d -t nix-rebuild-nixos_XXXX)"
    set result "$tempdir/result"
    set buildlog "$tempdir/buildlog.jsonish"
    set evalfile $FLAKE
    set attrpath "nixosConfigurations.\"$hostname\".config.system.build.toplevel"
    # set fullflake "$FLAKE#nixosConfigurations.\"$hostname\".config.system.build.toplevel"
    set profile /nix/var/nix/profiles/system
    set NIXOS_INSTALL_BOOTLOADER 1
    set -xl SHELL /bin/sh

    echo "Building $evalfile $attrpath"
    echo "Into $result"
    echo "With log $buildlog"

    command nix \
        build \
        --file $evalfile \
        $attrpath \
        --out-link $result --show-trace \
        --log-format internal-json -v \
        --impure \
        $XTRABUILDARGS &| tee $buildlog &| nom --json || begin
        echo "Failed to build $evalfile $attrpath"
        return 1
    end

    nvd diff $profile $result

    echo "Installing profile"
    sudo \
        nix-env \
        --profile \
        $profile \
        --set \
        $result || begin
        echo "Failed to set $result as $profile"
        return 1
    end

    echo "Testing $profile/bin/switch-to-configuration test"
    sudo -E systemd-run \
        -E LOCALE_ARCHIVE \
        -E NIXOS_INSTALL_BOOTLOADER \
        --collect \
        --no-ask-password \
        --pty \
        --quiet \
        --same-dir \
        --service-type=exec \
        --unit=nixos-switch \
        --wait \
        $profile/bin/switch-to-configuration test || begin
        echo "Test failed $profile/bin/switch-to-configuration test"
        return 1
    end

    echo -n "Activating in: "
    for i in (seq 3 -1 1)
        echo -n "$i "
        sleep 1
    end
    echo

    echo "Activating $profile/bin/switch-to-configuration switch"
    sudo -E systemd-run \
        -E LOCALE_ARCHIVE \
        -E NIXOS_INSTALL_BOOTLOADER \
        --collect \
        --no-ask-password \
        --pty \
        --quiet \
        --same-dir \
        --service-type=exec \
        --unit=nixos-switch \
        --wait \
        $profile/bin/switch-to-configuration switch || begin
        echo "Switch failed $profile/bin/switch-to-configuration switch"
        return 1
    end
    sudo sync

    rm -rf $tempdir
end
