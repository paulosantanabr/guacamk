#!/bin/bash

#0 - Credentials
#Apache Guacamole

loadcred () {
source cred.file
}

loadcred


#CONNECTIONID=$NOTIFY_HOSTLABEL_gcm_id
#PARENTID=$NOTIFY_HOSTLABEL_gcm_parentid

CONNECTIONID=$1
PARENTID=$2

#1 - Authentication
export TOKEN=$(curl -s -k -X POST  https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)

#curl -s -k -X DELETE https://$GCMSERVER/api/session/data/postgresql/connections/$CONNECTIONID?token=$TOKEN



#Check if the group is empty
CHECKGROUP=$(curl -s -k -X GET -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/connectionGroups/$PARENTID/tree?token=$TOKEN)

if [[ "$CHECKGROUP" == *"childConnection"* ]]; then
  echo . > /dev/null
  #echo "echo Connection ID: $CONNECTIONID Group ID $2 is Not Empty"
  else
  echo "echo Connection ID: $CONNECTIONID Group ID $2 is Empty and will be removed."
  #curl -s -k -X DELETE https://$GCMSERVER/api/session/data/postgresql/connectionGroups/$PARENTID?token=$TOKEN
  echo $CHECKGROUP
fi
