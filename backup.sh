#!/bin/bash

#Creating 7zip encrypted archive
cd /root/
7za a -y -tzip -pyourawesomepasswordbecauseyesyougiveafuckaboutsecurity -mem=AES256 `date +%Y%m%d`.full.7z /backup/*
mv `date +%Y%m%d`.full.7z /home/someuser/

#Storing old archive name
datediff30 = `date -d "today - 30 days" +%Y%m%d`.full.7z

#Sending / deleting archive to / from your awesome ftp storage
curl -T /home/someuser/`date +%Y%m%d`.full.7z ftp://server --user user:pass
curl --quote "-dele $datediff30" ftp://server --user user:pass

#Deleting all locales backup files
rm /backup/WWW/*.tar.gz
rm /backup/DBs/*.sql
rm /home/stylersnico/*.7z
