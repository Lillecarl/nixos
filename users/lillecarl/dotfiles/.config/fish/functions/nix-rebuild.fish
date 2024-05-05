function nix-rebuild
    argparse --min-args=1 -- $argv
    set target $argv[1]
    set install (echo $argv[2] || echo "n")
    # Where to store build output
    set result ""
    # Hash of all files in the repo
    set repohash (fd --hidden -t file --search-path $FLAKE -x sha1sum | sort | sha1sum)

    switch $target
        case os
            set -f result "$(mktemp -d -t nix-rebuild-os_XXXX)/result"
            set -f fullflake "$FLAKE#nixosConfigurations.\"$hostname\".config.system.build.toplevel"
            set -f profile /nix/var/nix/profiles/system
            set -f NIXOS_INSTALL_BOOTLOADER 1
            if test "$repohash" = "$_oshash"
                set nobuild
                set result $_ospath
            end
        case home
            set -f result "$(mktemp -d -t nix-rebuild-home_XXXX)/result"
            set -f fullflake "$FLAKE#homeConfigurations.\"$USER@$hostname\".activationPackage"
            set -f profile $HOME/.local/state/nix/profiles/home-manager
            if test "$repohash" = "$_homehash"
                set nobuild
                set result $_homepath
            end
            # Get all old cheaty symlinks
            set oldlinks (readlink -f $profile/home-files/.local/linkstate)
        case '*'
            nix-rebuild os $gogo
            nix-rebuild home $gogo
            return
    end

    if set -q nobuild
        echo "No changes detected, skipping build"
        echo "Bypass this by unsetting _oshash and/or _homehash"
    else
        echo "Building $fullflake"
        echo "Into $result"
        nom \
            build \
            $fullflake \
            --out-link $result

        # Build again impurely to get the trace log output
        # https://github.com/maralorn/nix-output-monitor/issues/128
        # https://github.com/maralorn/nix-output-monitor/issues/92
        # https://github.com/maralorn/nix-output-monitor/issues/128
        nix \
            build \
            $fullflake \
            --no-link \
            --impure

        if test $status != 0
            echo "Failed to build $fullflake"
            return 1
        end
    end

    nvd diff $profile $result

    if set -q test && test $install != y
        read -P "Do you want to continue? [y/N] " -n 1 switch
    else
        set switch y
    end

    switch $switch
        case y
            switch $target
                case os
                    echo "Activating $result/bin/switch-to-configuration switch"
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
                        $profile/bin/switch-to-configuration switch

                    if test $status != 0
                        echo "Failed to activate NixOS profile"
                        echo "Install anyways? [y/N]"
                        if test $(read) != y
                            return 1
                        end
                    end

                    # NixOS activation doesn't link the profile
                    echo "Linking $result to $profile"
                    sudo nix-env -p $profile --set $result
                    if test $status != 0
                        echo "Failed to set profile"
                        return 1
                    end

                case home
                    # home-manager links the profile itself.
                    echo "Activating package $result/activate"
                    $result/activate
                    if test $status != 0
                        echo "Failed to activate profile"
                        return 1
                    end
                    ln -f -s $HOME/.editorconfig /tmp/.editorconfig
                    #echo $FLAKE/tmp/linker.py $oldlinks $result/home-files/.local/linkstate
                    #$FLAKE/tmp/linker.py $oldlinks $profile/home-files/.local/linkstate
            end
            # If we don't accept we store the result and hash for instant apply later
        case '*'
            switch $target
                case os
                    set -U _oshash $repohash
                    set -U _ospath $result
                case home
                    set -U _homehash $repohash
                    set -U _homepath $result
            end
    end

    false && rm -rf $result
end
