function cdr
    set -f last_output (kitten @ get-text --extent last_non_empty_output)
    set -f dirname_output (dirname $last_output)

    if test -d $last_output
        cd $last_output
    else if test -d $dirname_output
        cd $dirname_output
    else
        echo "No directory to cd to"
    end
end
