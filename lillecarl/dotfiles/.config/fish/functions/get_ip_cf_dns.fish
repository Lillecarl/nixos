function get_ip_cf_dns
    dog ch txt whoami.cloudflare @1.1.1.1 --json | jq -r '.responses[].answers[].data.messages[]'
end
