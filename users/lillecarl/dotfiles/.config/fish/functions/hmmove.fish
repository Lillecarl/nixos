function hmmove --wraps=cat
    # Where we're moving from
    set -f oldpath (path resolve $argv[1])
    # Where the head of old path is
    set -f from $HOME
    # Where the new path head is
    set -f to $FLAKE/users/lillecarl/dotfiles
    # Where we're moving to
    set -f newpath (echo $oldpath | sed "s,$HOME,$FLAKE/users/lillecarl/dotfiles,g")
    # Create the directory we're moving to
    mkdir -p (dirname $newpath)
    # Move the old path to the new path
    mv $oldpath $newpath
    # Link the new path to the old path if it's a file
    if test -f $newpath
        ln -s $newpath $oldpath
    end
end
