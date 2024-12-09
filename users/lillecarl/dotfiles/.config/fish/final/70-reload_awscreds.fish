# reload AWS credentials by reloading direnv if we're within 30 minutes of expiration
function reload_awscreds -e fish_preexec
    # If we don't have aws credential expiration or direnv we do nothing
    if not set -q AWS_CREDENTIAL_EXPIRATION || not set -q DIRENV_FILE
        return
    end

    # Get current date in the same weird format AWS uses
    set CURDATE $(date -u +%Y-%m-%dT%H:%M:%SZ)
    # Convert our date to unixtime
    set CURSEC $(date '+%s' -d $CURDATE)
    # Convert AWS date to unixtime
    set AWSSEC $(date '+%s' -d $AWS_CREDENTIAL_EXPIRATION)

    # If we have less than 30 minutes left of credentials, reload with direnv
    if [ $(math $AWSSEC - $CURSEC) -le 1800 ]
        direnv reload
    end
end
