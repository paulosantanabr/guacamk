#!/bin/bash
# Apache Guacamole - Connection Removal

#0 - Credentials
#Apache Guacamole

loadcred () {
source cred.file
}

loadcred

#CONNECTIONID=$1
CONNECTIONID=$NOTIFY_HOSTLABEL_gcm_id
PARENTID=$NOTIFY_HOSTLABEL_gcm_parentid

#echo $GCMSERVER $GCMUSR GCMPWD $CONNECTIONID

#1 - Authentication
export TOKEN=$(curl -s -k -X POST  https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)

cmk_delete=$(curl -s -k -X DELETE https://$GCMSERVER/api/session/data/postgresql/connections/$CONNECTIONID?token=$TOKEN)

#Check if the group is empty
CHECKGROUP=$(curl -s -k -X GET -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/connectionGroups/$PARENTID/tree?token=$TOKEN)

if [[ "$CHECKGROUP" == *"childConnection"* ]]; then
  echo . > /dev/null
  echo "Connection ID: $CONNECTIONID Group ID $PARENTID is Not Empty" >> /var/log/guacamk-deletegroup.log
  GROUPREMOVAL="Not Empty"
  else
  echo "Connection ID: $CONNECTIONID Group ID $PARENTID is Empty and will be removed." >> /var/log/guacamk-deletegroup.log
  GROUPREMOVAL="Empty and Removed"
  curl -s -k -X DELETE https://$GCMSERVER/api/session/data/postgresql/connectionGroups/$PARENTID?token=$TOKEN
  #echo $CHECKGROUP
fi


echo Hostname: $NOTIFY_HOSTNAME / gcm_id: $NOTIFY_HOSTLABEL_gcm_id / gcm_parentid: $NOTIFY_HOSTLABEL_gcm_parentid / Action: DELETE / Integration: Apache Guacamole / Status: $cmk_delete / Group Status: $GROUPREMOVAL >> /var/log/guacamk-deleteconnection.log
echo Hostname: $NOTIFY_HOSTNAME / gcm_id: $NOTIFY_HOSTLABEL_gcm_id / gcm_parentid: $NOTIFY_HOSTLABEL_gcm_parentid / Action: DELETE / Integration: Apache Guacamole / Status: $cmk_delete / Group Status: $GROUPREMOVAL
