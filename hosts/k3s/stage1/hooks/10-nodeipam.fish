#! /usr/bin/env fish
#
# ADMISSION_RESPONSE_PATH
# CONVERSION_RESPONSE_PATH
# VALIDATING_RESPONSE_PATH
# KUBERNETES_PATCH_PATH
# METRICS_PATH

if test "$argv[1]" = --config
    cat ./lib/nodeipam-config.yaml
    exit 0
end

set BASEDIR ../

# Dev commands
cat $BINDING_CONTEXT_PATH >$BASEDIR/context.json
# env >$BASEDIR/variables.env

cat $BINDING_CONTEXT_PATH | ./lib/filter.jq 2>>$BASEDIR/jq.log | jq >$BASEDIR/output.json

# nix eval --json --file ./lib/filter.nix 2>>$BASEDIR/nix.log | jq >$BASEDIR/output.json
