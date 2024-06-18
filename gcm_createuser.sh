#!/bin/bash

loadcred () {
source cred.file
}

createuser() {
export TOKEN=$(curl -s -k -X POST https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)
gcm_status=$(curl -s -k -X POST -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/users?token=$TOKEN -->
date=$(date '+%Y-%m-%d %H:%M:%S')
echo $date / User: $gcm_usr / Password: $gcm_pwd / Status: $gcm_status
}

passwordgeneration() {
gcm_usr=$(echo $1)
gcm_pwd=$(echo Gcm!$1123@789)
}

loadcred
passwordgeneration $1
createuser
