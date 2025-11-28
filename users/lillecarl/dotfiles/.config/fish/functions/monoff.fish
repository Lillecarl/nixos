function monoff
    set --export NIRI_SOCKET /run/user/1000/niri.*.sock
    niri msg action power-off-monitors
end
