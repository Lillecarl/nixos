function rebuild-os
    set tempdir "$(mktemp -d -t nix-rebuild-home_XXXX)"
    set result "$tempdir/result"
    set buildlog "$tempdir/buildlog.jsonish"
    set fullflake "$FLAKE#nixosConfigurations.\"$hostname\".config.system.build.toplevel"
    set profile /nix/var/nix/profiles/system
    set NIXOS_INSTALL_BOOTLOADER 1

    echo "Building $fullflake"
    echo "Into $result"
    nom \
        build \
        $fullflake \
        --out-link $result || begin
        echo "Failed to build $fullflake"
        return 1
    end

    echo "Comparing previous and new profiles"
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

    rm -rf $tempdir
end
