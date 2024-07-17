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
cmk_delete=$(curl -s -k -X DELETE https://$GCMSERVER/api/session/data/postgresql/connections/$CONNECTIONID?token=$TOKEN)

echo Hostname: $NOTIFY_HOSTNAME / gcm_id: $NOTIFY_HOSTLABEL_gcm_id / gcm_parentid: $NOTIFY_HOSTLABEL_gcm_parentid / Action: DELETE / Integration: Apache Guacamole / Status: $cmk_delete >> /var/log/guacamk-deleteconnection.log
echo Hostname: $NOTIFY_HOSTNAME / gcm_id: $NOTIFY_HOSTLABEL_gcm_id / gcm_parentid: $NOTIFY_HOSTLABEL_gcm_parentid / Action: DELETE / Integration: Apache Guacamole / Status: $cmk_delete
