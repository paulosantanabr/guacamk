#!/bin/bash
#Documentation
#loadcred=Load credential file
#createuser=Create user on Apache Guacamole
#passwordgeneration=Generare a unique password
#assignpermission=Assign permissions to users

#Logs
#/var/log/guacamk-retrieveconnectionids.log
#/var/log/guacamk-createuser.log
#/var/log/guacamk-creategroup.log

#Debuging
#tail -f /var/log/guacamk-*

#Crontab
#crontab -e
#* * * * * /home/bitnami/gcm

cd /home/bitnami/

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

retrieveconnectiondetails() {
curl -s -k -X GET -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/connections?token=$TOKEN | jq > /tmp/gcm.json
}

readpermissiongroupnames() {
filename=/tmp/gcm_ids.file
while IFS= read -r CONNECTIONID;
do
cat /tmp/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].name' | tr -d '"' | cut -c 5-12 >> /tmp/gcm_permissions.file
done < "$filename"
}

removerepetitiveentries() {
cat -n /tmp/gcm_permissions.file | sort -uk2 | sort -nk1 | cut -f2- >> /tmp/gcm_permissions2.file
rm /tmp/gcm_permissions.file
mv /tmp/gcm_permissions2.file /tmp/gcm_permissions.file
}

createuser() {
filename=/tmp/gcm_permissions.file
while IFS= read -r gcm_usr;
do
passwordgeneration $gcm_usr
gcm_status=$(curl -s -k -X POST -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/users?token=$TOKEN --data-binary '{"username":"'"$gcm_usr"'","password":"'"$gcm_pwd"'","attributes":{}}')
echo $date / User: $gcm_usr / Password: $gcm_pwd / Status: $gcm_status >> /var/log/guacamk-createuser.log
done < "$filename"
}

creategroup() {
filename=/tmp/gcm_permissions.file
while IFS= read -r GROUPNAME;
do
gcm_status=$(curl -s -k -X POST -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/userGroups?token=$TOKEN --data-binary '{"identifier":"'"$GROUPNAME"'","parameters": {},"attributes":{}}')
echo $date / Group: $GROUPNAME / Status: $gcm_status >> /var/log/guacamk-creategroup.log
done < "$filename"
}

assigngrouppermission() {
filename=/tmp/gcm_ids.file
while IFS= read -r CONNECTIONID;
do
CHECKCONNECTIONID=$(cat /tmp/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].name' | tr -d '"' | cut -c 5-12)
CHECKNAME=$(cat /tmp/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].name' | tr -d '"')
CHECKCONNECTIONPARENTID=$(cat /tmp/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].parentIdentifier' | tr -d '"')
curl -s -k -X PATCH -H 'Content-Type: application/json' -H 'Accept: application/json' https://$GCMSERVER/api/session/data/postgresql/userGroups/$CHECKCONNECTIONID/permissions?token=$TOKEN -d '[ { "op": "add","path": "/connectionPermissions/'$CONNECTIONID'","value": "READ"} ]'
curl -s -k -X PATCH -H 'Content-Type: application/json' -H 'Accept: application/json' https://$GCMSERVER/api/session/data/postgresql/userGroups/$CHECKCONNECTIONID/permissions?token=$TOKEN -d '[ { "op": "add","path": "/connectionGroupPermissions/'$CHECKCONNECTIONPARENTID'","value": "READ"} ]'
done < "$filename"
}

assignuserpermission() {
filename=/tmp/gcm_permissions.file
while IFS= read -r GROUPNAME;
do
curl -s -k -X PATCH -H 'Content-Type: application/json' -H 'Accept: application/json' https://$GCMSERVER/api/session/data/postgresql/userGroups/"$GROUPNAME"/memberUsers?token=$TOKEN -d '[ { "op": "add","path": "/","value": "'"$GROUPNAME"'"} ]'
done < "$filename"
}

passwordgeneration() {
gcm_pwd=$(echo Gcm!$1123@789)
}

loadcred
authentication
retrieveconnectionids
retrieveconnectiondetails
readpermissiongroupnames
removerepetitiveentries
creategroup
assigngrouppermission
createuser
assignuserpermission
