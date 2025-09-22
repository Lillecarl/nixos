function readwhich
    readlink -f $(which $argv[1])
end
