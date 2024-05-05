function aws-assume-exec
    set arn $argv[1]
    set command $argv[2..-1]
    set sessionname "assume_exec_$(date +%s)"
    begin
        set json $(aws sts assume-role --role-arn "$arn" --role-session-name $sessionname)
        set -lx AWS_ACCESS_KEY_ID $(echo $json | jq -r '.Credentials|.AccessKeyId')
        set -lx AWS_SECRET_ACCESS_KEY $(echo $json | jq -r '.Credentials|.SecretAccessKey')
        set -lx AWS_SESSION_TOKEN $(echo $json | jq -r '.Credentials|.SessionToken')
        set -lx AWS_CREDENTIAL_EXPIRATION $(echo $json | jq -r '.Credentials|.Expiration')
        set -lx AWS_ROLE_SESSION_NAME $(echo $json | jq -r '.AssumedRoleUser|.Arn')
        set -lx AWS_ROLE_ARN $arn
        command $command
    end
end
