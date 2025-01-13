function graphrun
    set ocd $PWD
    set root $FLAKE/cloud
    if test $ocd = $root
        set states (just (just --summary | string split " "))
    else
        set states (just (basename $PWD))
    end
    echo States: $states
    for state in $states
        cd $root/$state
        # Dont run plan if source hasn't changed
        echo -n Testing $state
        test (shadir) = (cat .shadir 2>/dev/null || echo "lol") && echo " cached" && continue || echo ""
        # Run terranix if config exists 
        if test -f config.nix
            # default to tofu in Terranix state
            set --function cmd tofu
            echo Nixxing $state
            terranix >terranix.tmp && mv terranix.tmp config.tf.json || rm terranix.tmp
        end
        # If terragrunt file exists we run state with terragrunt
        if test -f terragrunt.hcl
            set --function cmd terragrunt
        end
        echo -n "Planning $state: "
        $cmd plan -detailed-exitcode &>/dev/null
        switch $status
            case 0
                echo succeeded with no diff
                shadir >.shadir
            case 1
                echo errored
                $cmd plan
            case 2
                echo succeeded with diff
                $cmd apply && shadir >.shadir
        end
    end
    cd $ocd
end
