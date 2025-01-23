function padd
    for package in $argv
        for path in $(nix build nixpkgs#$package.out --print-out-paths --no-link)
            set bin "$path/bin"
            if ! test -d $bin
                echo "$bin doesn't exist"
            else if contains $PATH $bin
                echo "$bin is already on PATH"
            else
                echo "Added $bin to PATH"
                set --prepend --global PATH $bin
            end
        end
    end
end
