# guacamk
Integration Between Checkmk and Apache Guacamole for Monitoring of the Server and Connections

Requirements:
  - checkmk 2.2+ (Raw/Enterprise/Cloud)
  - jq



Understanding the process:

  1 - Apache Guacamole - Authentication
  2 - Apache Guacamole - Retrieve Connection IDs
  3 - Apache Guacamole - Retrieve Connection Details
  4 - Apache Guacamole - Retrieve Connection Details with IP Addresses
  5 - Checkmk - Retrieve hosts
  6 - Checkmk - Create new hosts
  7 - Checkmk - Activate Changes
  8 - Cleanup files




![image](https://github.com/pauloadrianodotcom/guacamk/assets/121560100/534fd4bf-1d40-4042-9dde-969eef678af2)


Installation

 gethosts.mk

    Folder Structure

      ./guacamk
      ./guacamk/files
      .guacamk/logs

  
  gcm_connections.mk
  gcm_sync.mk


  cmk_gethosts.cmk - Retrieve Hosts from Checkmk
  cmk_createhosts.cmk - Create new hosts into Checkmk


  
  
cmk_notification_deletehosts.sh - Delete hosts using a notification

  cmkdeletehosts.cmk
  cmk_createhosts.cmk



      ./files/

=================================================
Create a folder called guacamk

Create a file called guacamk.sh








