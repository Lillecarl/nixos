function git_fetch --on-variable PWD
    set time (date +%s)
    set varname "_git_fetch_last_$(echo $PWD | base64)"

    if not set -q git_fetch_interval
        set -g git_fetch_interval 3600
    end

    if true &&
            test $time -gt $(math $$varname + $git_fetch_interval) &&
            fd -I -d 1 -t d -H -q .git &&
            test $(nmcli -t g | awk -F ':' '{ print $2 }') = full


        git fetch --all --recurse-submodules &&
            echo fetched &&
            set -U $varname $time
    end
end