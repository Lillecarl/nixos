function agenix
    pushd $FLAKE/secrets || return 1
    command agenix --identity $HOME/.ssh/agenix $argv
    popd
end
