function _fish_direnv_hook --on-variable PWD
    direnv status --json | jq -e '.state.foundRC.allowed == 0' >/dev/null || return 1

    # Set last PWD to current if last doesn't exist
    set -q _fish_direnv_last_pwd || set -U _fish_direnv_last_pwd $PWD

    # Set out and in files
    set out_file $_fish_direnv_last_pwd/.out.fish
    set in_file $PWD/.in.fish

    # Check if out and in files exist and source them
    test -f $out_file && source $out_file
    test -f $in_file && source $in_file

    # Set previous dir so we can run unload scripts too
    set -U _fish_direnv_last_pwd $PWD
end
