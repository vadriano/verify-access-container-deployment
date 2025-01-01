#!/bin/bash
# This script will fetch the user/rw.pwd from the installed Verify Access Operator,
# then attempt to upload the given snapshot ID to the Operator's managed snapshot 
# service.

for COMMAND in jq oc; do
    if ! command -v $COMMAND &> /dev/null
    then
        echo "$COMMAND CLI tool missing"
        return 1
    fi
done

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 <config_container_id> <snapshot_id>"
    exit 2
fi

# Get the verify-access-operator's properties to upload snapshots
OPERATOR_SECRET="$(oc get secret -n openshift-operators verify-access-operator -o json )"

if [ -z "$OPERATOR_SECRET" ]; then
    echo "Verify Access Operator snapshot service secret does not exist or can not be read"
    exit 3
fi

# Upload the snapshot
URL="$( echo "$OPERATOR_SECRET" | jq -cr '.data.url' | base64 -d )"
USER="$( echo "$OPERATOR_SECRET" | jq -cr '.data.user' | base64 -d )"
SECRET="$( echo "$OPERATOR_SECRET" | jq -cr '.data."rw.pwd"' | base64 -d )"
RSP=$(oc exec -t $1 -- curl -k -u $USER:$SECRET -X GET $URL/snapshots)
echo $RSP | jq .
