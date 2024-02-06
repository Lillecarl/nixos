function hmmove --wraps=cat
    # Where we're moving from
    set -f oldpath $argv[1]
    # Where the head of old path is
    set -f from $HOME
    # Where the new path head is
    set -f to $FLAKE/lillecarl/dotfiles
    # Where we're moving to
    set -f newpath (echo $oldpath | sed "s,$HOME,$FLAKE/lillecarl/dotfiles,g")
    # Create the directory we're moving to
    mkdir -p (dirname $newpath)
    # Move the old path to the new path
    mv $oldpath $newpath
end
