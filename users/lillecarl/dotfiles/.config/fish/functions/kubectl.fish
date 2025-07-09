function kubectl --wraps=kubectl
    set command $argv[1]
    set args $argv
    set --erase args[1]

    if test $command = list
        kubectl get pods \
            --all-namespaces=true \
            --output=custom-columns=NAMESPACE:".metadata.namespace",NAME:".metadata.name",STATUS:".status.phase" \
            $args
    else if test $command = podclean
        set podlist (kubectl list --no-headers=true)
        for i in $podlist
            set pns (echo $i | awk '{print $1}')
            set pname (echo $i | awk '{print $2}')
            set pstatus (kubectl get pods -n $pns $pname -ojson | jq -r '.status.phase')
            if true && # Just here to trick the indenter
                    test "$pns" != kube-system &&
                    test "$pstatus" != Running
                # test "$pstatus" != Completed &&
                # test "$pstatus" != Succeeded

                echo "Removing $pname from $pns with status $pstatus"
                kubectl -n $pns delete pod $pname &
            end
        end
    else
        command kubectl $argv
    end
end
