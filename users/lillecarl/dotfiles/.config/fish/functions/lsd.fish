function lsd
    if set --query NERDFONTS
        command lsd --icon-theme fancy $argv
    else
        command lsd --icon-theme unicode $argv
    end
end
