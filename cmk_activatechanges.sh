#!/bin/bash

# NOTE: We recommend all shell users to use the "httpie" examples instead.

HOST_NAME=$1
SITE_NAME=$2
API_URL="http://$HOST_NAME/$SITE_NAME/check_mk/api/1.0"

USERNAME=$3
PASSWORD=$4

out=$(
  curl -L \
    --silent \
    --write-out "\nxxx-status_code=%{http_code}\n" \
    --header "Authorization: Bearer $USERNAME $PASSWORD" \
    --header "Accept: application/json" \
    --header "If-Match: "*"" \
    --header "Content-Type: application/json" \
    --data '{
          "force_foreign_changes": true,
          "redirect": false,
          "sites": [
            "central"
          ]
        }' \
    "$API_URL/domain-types/activation_run/actions/activate-changes/invoke")

resp=$( echo "${out}" | grep -v "xxx-status_code" )
code=$( echo "${out}" | awk -F"=" '/^xxx-status_code/ {print $2}')

# For indentation, please install 'jq' (JSON query tool)
echo "$resp" | jq
# echo "$resp"

if [[ $code -lt 400 ]]; then
    echo "OK"
    exit 0
else
    echo "Request error"
    exit 1
fi
