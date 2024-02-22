# guacamk
Integration Between Checkmk and Apache Guacamole for Monitoring of the Server and Connections


Requiriments
  checkmk 2.2+ (Raw/Enterprise/Cloud)
  jq


First Step

  Connect to Apache Guacamole to retrieve connections:




Installation

 gethosts.mk

    Folder Structure

      ./guacamk
      ./guacamk/files

  cmk_gethosts.cmk
  gcm_connections.mk
  gcm_sync.mk
  
cmk_notification_deletehosts.sh - Delete hosts using a notification

  cmkdeletehosts.cmk
  cmk_createhosts.cmk



      ./files/

=================================================
Create a folder called guacamk

Create a file called guacamk.sh








