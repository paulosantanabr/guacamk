#!/bin/bash

HOST_NAME="localhost:8000"
SITE_NAME="cmk"
API_URL="http://$HOST_NAME/$SITE_NAME/check_mk/api/1.0"

USERNAME="cmkadmin"
PASSWORD="pa55wrd"

connectionid="$1"
name="$2"
ip="$3"
protocol="$4"



out=$(
  curl \
    --silent \
    --request POST \
    --write-out "\nxxx-status_code=%{http_code}\n" \
    --header "Authorization: Bearer $USERNAME $PASSWORD" \
    --header "Accept: application/json" \
    --header "Content-Type: application/json" \
    --data '{
          "attributes": {
            "ipaddress": "'$ip'",
            "labels": {
            "guaca_protocol": "'$protocol'"
          }
          },
          "folder": "/",
          "host_name": "'$name'"
        }' \
    "$API_URL/domain-types/host_config/collections/all")

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
