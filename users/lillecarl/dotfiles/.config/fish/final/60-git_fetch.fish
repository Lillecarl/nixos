function git_fetch --on-variable PWD
    return 0
    set time (date +%s)
    set varname "_git_fetch_last_$(echo $PWD | md5sum | cut -c 1-6)"

    if not set -q git_fetch_interval
        set -U git_fetch_interval 3600
    end

    set -g _git_fetch_var_name $varname

    if true &&
            test $time -gt $(math $$varname + $git_fetch_interval) &&
            fd -I -d 1 -t d -H -q '^.git$' &&
            test $(nmcli -t g | awk -F ':' '{ print $2 }') = full

        echo "Fetching git repos in $PWD"

        systemd-run --user --quiet --unit $varname fish -c "git fetch --all --recurse-submodules && set -U $varname $time"
    end
end
