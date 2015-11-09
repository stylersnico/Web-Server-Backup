#!/bin/bash

##############################
###backup of the WWW folder###
##############################

#Go to working dir
cd /backup/WWW/

#Create a backup of all the /var/www/ dir
tar -czf `date +%Y%m%d`.www.tar.gz /var/www/


#############################
###backup of the databases###
#############################

#Variables
USER="root"
PASSWORD="yourrootpasswordofmysqlormariadb"
OUTPUT="/backup/DBs"

#Go to working dir
cd /backup/DBs/

#Extract all databases
databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

#Backup all databases
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump -u $USER -p$PASSWORD --databases $db > `date +%Y%m%d`.$db.sql
    fi
done


##################################
###Send to external FTP storage###
##################################

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
rm /home/someuser/*.7z
