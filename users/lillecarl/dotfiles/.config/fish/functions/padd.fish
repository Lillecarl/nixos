function padd
    for path in $(nix build nixpkgs#$argv[1] --print-out-paths --no-link)
        set bin "$path/bin"
        if test -d $bin
            echo "Added $bin to PATH"
            set --prepend --global PATH $bin
        end
    end
end
