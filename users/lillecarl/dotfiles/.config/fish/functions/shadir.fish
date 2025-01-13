function shadir
    fd ".+\.nix|.+\.tf|.+\.hcl|.+\.yaml|.+\.tf\.json" | sort | xargs sha1sum | sha1sum | awk '{ print $1 }'
end
