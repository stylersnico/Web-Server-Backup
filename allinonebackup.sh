#!/bin/bash

###############
###Variables###
###############

#backup of the WWW folder
WWWBACKUPDIR="/backup/WWW/"

#backup of the databases
DBBACKUPDIR="/backup/DBs/"
DBUSER="root"
DBPASSWORD="yourrootpasswordofmysqlormariadb"

#Send to external FTP storage
ROOTFOLDER="/backup/*"
ARCHIVEPASSWORD="yourawesomepasswordbecauseyesyougiveafuckaboutsecurity"
ARCHIVEFOLDER="/home/someuser/"
FTPSERVER="server"
FTPUSER="user"
FTPPASS="pass"


##############################
###backup of the WWW folder###
##############################

#Go to working dir
cd $WWWBACKUPDIR

#Create a backup of all the /var/www/ dir
tar -czf `date +%Y%m%d`.www.tar.gz /var/www/


#############################
###backup of the databases###
#############################

#Go to working dir
cd $DBBACKUPDIR

#Extract all databases
databases=`mysql -u $DBUSER -p$DBPASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

#Backup all databases
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump -u $DBUSER -p$DBPASSWORD --databases $db > `date +%Y%m%d`.$db.sql
    fi
done


##################################
###Send to external FTP storage###
##################################

#Creating 7zip encrypted archive
cd /root/
7za a -y -tzip -p$ARCHIVEPASSWORD -mem=AES256 `date +%Y%m%d`.full.7z $ROOTFOLDER
mv `date +%Y%m%d`.full.7z $ARCHIVEFOLDER

#Storing old archive name
datediff=`date -d "today - 30 days" +%Y%m%d`.full.7z

#Sending / deleting archive to / from your awesome ftp storage
curl -T $ARCHIVEFOLDER`date +%Y%m%d`.full.7z ftp://$FTPSERVER --user $FTPUSER:$FTPPASS
curl --quote "-dele $datediff" ftp://$FTPSERVER --user $FTPUSER:$FTPPASS

#Deleting all locales backup files
cd $DBBACKUPDIR
rm `date +%Y%m%d`.*.tar.gz
cd $WWWBACKUPDIR
rm `date +%Y%m%d`.*.sql
cd $ARCHIVEFOLDER
rm `date +%Y%m%d`.*.full.7z
