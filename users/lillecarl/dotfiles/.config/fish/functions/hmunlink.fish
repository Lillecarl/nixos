function hmunlink --wraps=cat
    # Where we're moving from
    set -f oldpath $argv[1]
    set -f tmppath "$oldpath.tmp"
    set -f newpath $oldpath
    mv $oldpath $tmppath
    cp $tmppath $newpath
    rm $tmppath || unlink $tmppath
end
