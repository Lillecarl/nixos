#! /usr/bin/env fish
#
# Function that runs when PWD changes.
# Universal variables are shared across fish sessions
# Global variables stays within your fish session
# We use this to store changes globally but compare changes locally

# Set LASTPATH when directory changes
function __set_lastpath --on-variable PWD
    if test "$PWD" != "$SLASTPATH"
        set --universal LASTPATH "$PWD"
        set --global SLASTPATH "$PWD"
    end
end

# Initialize on shell startup
set --global SLASTPATH "$PWD"
