function lsd
    if set --query NERDFONTS
        command lsd --icon always $argv
    else
        command lsd --icon never $argv
    end
end
