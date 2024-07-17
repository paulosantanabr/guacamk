#!/bin/bash
# Apache Guacamole - Connection Removal

#0 - Credentials
#Apache Guacamole
GCMSERVER=
GCMUSR=
GCMPWD=
#CONNECTIONID=$1
CONNECTIONID=$NOTIFY_HOSTLABEL_gcm_id

#echo $GCMSERVER $GCMUSR GCMPWD $CONNECTIONID

#1 - Authentication
export TOKEN=$(curl -s -k -X POST  https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)

curl -s -k -X DELETE https://$GCMSERVER/api/session/data/postgresql/connections/$CONNECTIONID?token=$TOKEN

