#!/bin/bash
#CHECKMK Delete

HOST_NAME="localhost"
SITE_NAME="central"
API_URL="http://$HOST_NAME/$SITE_NAME/check_mk/api/1.0"

USERNAME=""
PASSWORD=""

name="$NOTIFY_HOSTNAME"

out=$(
  curl \
    --request DELETE \
    --silent \
    --write-out "\nxxx-status_code=%{http_code}\n" \
    --header "Authorization: Bearer $USERNAME $PASSWORD" \
    --header "Accept: application/json" \
    "$API_URL/objects/host_config/$name")

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

