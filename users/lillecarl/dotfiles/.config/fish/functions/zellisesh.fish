function zellisesh
    # Make sure to source all configs on new shell instances from zellij
    set --erase __HM_SESS_VARS_SOURCED
    set --erase __fish_home_manager_config_sourced
    # Attach to a zellij session if it exists, otherwise start a new one
    # unset SHLVL so prompt doesn't show as a nested session
    zellij attach 2>/dev/null || env -u SHLVL zellij
end
