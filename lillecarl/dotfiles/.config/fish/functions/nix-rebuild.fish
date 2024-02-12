function nix-rebuild --argument target gogo
    # Where to store build output
    set result "$(mktemp -d -t nix-rebuild_XXXX)/result"
    # Common arguments for nix build
    #set common_args --impure --out-link $result --verbose --log-format internal-json
    set common_args --out-link $result --verbose --log-format internal-json
    # Hash of all files in the repo
    set repohash (fd --hidden -t file --search-path $FLAKE -x sha1sum | sort | sha1sum)

    switch $target
        case os
            set fullflake "$FLAKE#nixosConfigurations.\"$hostname\".config.system.build.toplevel"
            set profile /nix/var/nix/profiles/system
            set NIXOS_INSTALL_BOOTLOADER 1
            if test "$repohash" = "$_oshash"
                set nobuild
                set result $_ospath
            end
        case home
            set fullflake "$FLAKE#homeConfigurations.\"$USER@$hostname\".activationPackage"
            set profile $HOME/.local/state/nix/profiles/home-manager
            if test "$repohash" = "$_homehash"
                set nobuild
                set result $_homepath
            end
            # Get all old cheaty symlinks
            set oldlinks (readlink -f $profile/home-files/.local/linkstate)
        case '*'
            nix-rebuild os || return $status
            nix-rebuild home || return $status
            return
    end

    if set -q nobuild
        echo "No changes detected, skipping build"
        echo "Bypass this by unsetting _oshash and/or _homehash"
    else
        echo "Building $fullflake"
        echo "Into $result"
        nix \
            build \
            $fullflake \
            $common_args &| nom --json

        if test $status != 0
            echo "Failed to build $fullflake"
            return 1
        end
    end

    nvd diff $profile $result

    if not set -q gogo
        read -P "Do you want to continue? [y/N] " -n 1 switch
    else
        set switch y
    end

    switch $switch
        case y
            # Link the new profile
            #if test $target = os
            #    sudo nix-env -p $profile --set $result
            #else
            #    nix-env -p $profile --set $result
            #end
            #if test $status != 0
            #    echo "Failed to set profile"
            #    return 1
            #end
            # Run activation script
            switch $target
                case os
                    # NixOS activation doesn't link the profile
                    echo "Linking $result to $profile"
                    sudo nix-env -p $profile --set $result
                    if test $status != 0
                        echo "Failed to set profile"
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
                        $profile/bin/switch-to-configuration switch

                    if test $status != 0
                        echo "Failed to activate profile"
                        echo "Please note that you'll still boot into this generation"
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
end
