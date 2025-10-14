function ninitctl --wraps=dinitctl
    dinitctl --socket-path /run/user/$(id -u)/niri-dinit.socket $argv
end
