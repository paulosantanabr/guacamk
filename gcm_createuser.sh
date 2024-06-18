#!/bin/bash
GCMSERVER=
GCMUSR=
GCMPWD=

gcm_usr=
gcm_pwd=

passwordgeneration() {
gcm_pwd=$(echo Gcm!$1123@789)
echo $gcm_pwd
}

export TOKEN=$(curl -s -k -X POST https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)

curl -s -k -X POST -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/users?token=$TOKEN --data-binary '{"username":"'"$gcm_usr"'","password":"'"$gcm_pwd"'","attributes":{}}'
