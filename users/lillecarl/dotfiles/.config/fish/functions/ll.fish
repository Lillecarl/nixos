function ll --wraps='ls -l' --wraps='lsd -l'
    lsd -l $argv
end
