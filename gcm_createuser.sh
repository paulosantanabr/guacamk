#!/bin/bash
#Documentation
#loadcred=Load credential file
#createuser=Create user on Apache Guacamole
#passwordgeneration=Generare a unique password
#assignpermission=Assign permissions to users


#Logs
#/var/log/guacamk-retrieveconnectionids.log
#/var/log/guacamk-createuser.log

loadcred () {
source cred.file
}

authentication() {
export TOKEN=$(curl -s -k -X POST  https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)
}

date=$(date '+%Y-%m-%d %H:%M:%S')

retrieveconnectionids() {
curl -s -k -X GET -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/connections?token=$TOKEN | jq | grep -o '"identifier":\s*"[0-9]\+"' | tr -d '"identifier": ' > /tmp/gcm_ids.file
export IDCOUNT=$(wc -l /tmp/gcm_ids.file)
echo $date / Collected IDs: $IDCOUNT >> /var/log/guacamk-retrieveconnectionids.log
}

createuser() {
gcm_status=$(curl -s -k -X POST -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/users?token=$TOKEN --data-binary '{"username":"'"$gcm_usr"'","password":"'"$gcm_pwd"'","attributes":{}}')
#date=$(date '+%Y-%m-%d %H:%M:%S')
echo $date / User: $gcm_usr / Password: $gcm_pwd / Status: $gcm_status >> /var/log/guacamk-createuser.log
}

passwordgeneration() {
gcm_usr=$(echo $1)
gcm_pwd=$(echo Gcm!$1123@789)
}

loadcred
authentication
retrieveconnectionids
passwordgeneration $1
createuser
